_download_ndk_r17c() {
	if [ ! -f $TERMUX_COMMON_CACHEDIR/older-ndk/.placeholder-android-ndk-r17c ]; then
		echo "Start downloading Android NDK toolchain (version r17c)..."
		mkdir -p $TERMUX_COMMON_CACHEDIR/older-ndk/
		local _NDK_ARCHIVE_FILE=$TERMUX_COMMON_CACHEDIR/older-ndk/android-ndk-r17c-linux-x86_64.zip
		local _NDK_URL=https://dl.google.com/android/repository/android-ndk-r17c-linux-x86_64.zip
		local _NDK_SHA256=3f541adbd0330a9205ba12697f6d04ec90752c53d6b622101a2a8a856e816589
		termux_download $_NDK_URL $_NDK_ARCHIVE_FILE $_NDK_SHA256
		unzip -d $TERMUX_COMMON_CACHEDIR/older-ndk/ $_NDK_ARCHIVE_FILE > /dev/null 2>&1
		touch $TERMUX_COMMON_CACHEDIR/older-ndk/.placeholder-android-ndk-r17c
		echo "Downloading completed."
	fi
}

_setup_standalone_toolchain_ndk_r17c() {
	_download_ndk_r17c

	local TOOLCHAIN_DIR="$1"
	rm -rf $TOOLCHAIN_DIR

	local _NDK_ARCH
	if [ "$TERMUX_ARCH" == "aarch64" ]; then
		_NDK_ARCH="arm64"
	elif [ "$TERMUX_ARCH" == "arm" ]; then
		_NDK_ARCH="arm"
	elif [ "$TERMUX_ARCH" == "x86_64" ]; then
		_NDK_ARCH="x86_64"
	elif [ "$TERMUX_ARCH" == "i686" ]; then
		_NDK_ARCH="x86"
	fi

	# Setup a standalone toolchain
	python $TERMUX_COMMON_CACHEDIR/older-ndk/android-ndk-r17c/build/tools/make_standalone_toolchain.py \
				--arch $_NDK_ARCH --api $TERMUX_PKG_API_LEVEL --install-dir $TOOLCHAIN_DIR

	# Modify sysroot
	pushd $TOOLCHAIN_DIR

	# See https://github.com/android/ndk/issues/215#issuecomment-524293090
	sed -i "s/include_next <stddef.h>/include <stddef.h>/" include/c++/4.9.x/cstddef

	cd $TOOLCHAIN_DIR/sysroot

	# Apply patches
	for f in $TERMUX_SCRIPTDIR/common-files/ndk-patches-r17c/*.patch; do
		echo "Applying ndk-patch: $(basename $f)"
		sed "s%\@TERMUX_PREFIX\@%${TERMUX_PREFIX}%g" "$f" | \
			sed "s%\@TERMUX_HOME\@%${TERMUX_ANDROID_HOME}%g" | \
			patch --silent -p1;
	done

	# libintl.h: Inline implementation gettext functions.
	# langinfo.h: Inline implementation of nl_langinfo().
	cp "$TERMUX_SCRIPTDIR"/ndk-patches/{libintl.h,langinfo.h} usr/include

	# Remove <sys/capability.h> because it is provided by libcap.
	# Remove <sys/shm.h> from the NDK in favour of that from the libandroid-shmem.
	# Remove <sys/sem.h> as it doesn't work for non-root.
	# Remove <glob.h> as we currently provide it from libandroid-glob.
	# Remove <iconv.h> as it's provided by libiconv.
	# Remove <zlib.h> and <zconf.h> as we build our own zlib.
	# Remove KRH/khrplatform.h provided by mesa.
	rm usr/include/{sys/{capability,shm,sem},{glob,iconv,zlib,zconf},KHR/khrplatform}.h

	sed -i "s/define __ANDROID_API__ __ANDROID_API_FUTURE__/define __ANDROID_API__ $TERMUX_PKG_API_LEVEL/" \
		usr/include/android/api-level.h
	popd
}

_setup_toolchain_ndk_r17c() {
	local _NDK_TOOLCHAIN="$1"
	rm -rf $_NDK_TOOLCHAIN

	export CFLAGS=""
	export CPPFLAGS=""
	export LDFLAGS="-L${TERMUX_PREFIX}/lib"

	export AS=$TERMUX_HOST_PLATFORM-gcc
	export CC=$TERMUX_HOST_PLATFORM-gcc
	export CXX=$TERMUX_HOST_PLATFORM-g++
	export CPP=$TERMUX_HOST_PLATFORM-cpp
	export LD=$TERMUX_HOST_PLATFORM-ld
	export AR=$TERMUX_HOST_PLATFORM-ar
	export OBJCOPY=$TERMUX_HOST_PLATFORM-objcopy
	export OBJDUMP=$TERMUX_HOST_PLATFORM-objdump
	export RANLIB=$TERMUX_HOST_PLATFORM-ranlib
	export READELF=$TERMUX_HOST_PLATFORM-readelf
	export STRIP=$TERMUX_HOST_PLATFORM-strip
	export NM=$TERMUX_HOST_PLATFORM-nm

	if [ "$TERMUX_ON_DEVICE_BUILD" = "false" ]; then
		export PATH=$_NDK_TOOLCHAIN/bin:$PATH
		export CC_FOR_BUILD=gcc
		export PKG_CONFIG=$TERMUX_STANDALONE_TOOLCHAIN/bin/pkg-config
		export PKGCONFIG=$PKG_CONFIG
		export CCTERMUX_HOST_PLATFORM=$TERMUX_HOST_PLATFORM$TERMUX_PKG_API_LEVEL
		if [ $TERMUX_ARCH = arm ]; then
			CCTERMUX_HOST_PLATFORM=armv7a-linux-androideabi$TERMUX_PKG_API_LEVEL
		fi
		LDFLAGS+=" -Wl,-rpath=$TERMUX_PREFIX/lib"
	else
		export CC_FOR_BUILD=$CC
		# Some build scripts use environment variable 'PKG_CONFIG', so
		# using this for on-device builds too.
		export PKG_CONFIG=pkg-config
	fi
	export PKG_CONFIG_LIBDIR="$TERMUX_PKG_CONFIG_LIBDIR"

	if [ "$TERMUX_ARCH" = "arm" ]; then
		# https://developer.android.com/ndk/guides/standalone_toolchain.html#abi_compatibility:
		# "We recommend using the -mthumb compiler flag to force the generation of 16-bit Thumb-2 instructions".
		# With r13 of the ndk ruby 2.4.0 segfaults when built on arm with clang without -mthumb.
		CFLAGS+=" -march=armv7-a -mfpu=neon -mfloat-abi=softfp -mthumb"
		LDFLAGS+=" -march=armv7-a"
	elif [ "$TERMUX_ARCH" = "i686" ]; then
		# From $NDK/docs/CPU-ARCH-ABIS.html:
		CFLAGS+=" -march=i686 -msse3 -mstackrealign -mfpmath=sse"
		# i686 seem to explicitly require -fPIC, see
		# https://github.com/termux/termux-packages/issues/7215#issuecomment-906154438
		CFLAGS+=" -fPIC"
	elif [ "$TERMUX_ARCH" = "aarch64" ]; then
		:
	elif [ "$TERMUX_ARCH" = "x86_64" ]; then
		:
	else
		termux_error_exit "Invalid arch '$TERMUX_ARCH' - support arches are 'arm', 'i686', 'aarch64', 'x86_64'"
	fi

	# Android 7 started to support DT_RUNPATH (but not DT_RPATH).
	LDFLAGS+=" -Wl,--enable-new-dtags"

	# Avoid linking extra (unneeded) libraries.
	LDFLAGS+=" -Wl,--as-needed"

	# Basic hardening.
	CFLAGS+=" -fstack-protector-strong"
	LDFLAGS+=" -Wl,-z,relro,-z,now"

	if [ "$TERMUX_DEBUG_BUILD" = "true" ]; then
		CFLAGS+=" -g3 -O1"
		CPPFLAGS+=" -D_FORTIFY_SOURCE=2 -D__USE_FORTIFY_LEVEL=2"
	else
		CFLAGS+=" -O3"
	fi

	export CXXFLAGS="$CFLAGS"
	CPPFLAGS+=" -I${TERMUX_PREFIX}/include"

	# If libandroid-support is declared as a dependency, link to it explicitly:
	if [ "$TERMUX_PKG_DEPENDS" != "${TERMUX_PKG_DEPENDS/libandroid-support/}" ]; then
		LDFLAGS+=" -Wl,--no-as-needed,-landroid-support,--as-needed"
	fi

	export ac_cv_func_getpwent=no
	export ac_cv_func_endpwent=yes
	export ac_cv_func_getpwnam=no
	export ac_cv_func_getpwuid=no
	export ac_cv_func_sigsetmask=no
	export ac_cv_c_bigendian=no

	_setup_standalone_toolchain_ndk_r17c $_NDK_TOOLCHAIN
}

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

_setup_toolchain_ndk_r17c_envs() {
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
		export PATH=$GCC_STANDALONE_TOOLCHAIN/bin:$PATH
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
}

_setup_toolchain_ndk_r17c_envs_with_fc() {
	_setup_toolchain_ndk_r17c_envs

	# Set FC
	export FC=$TERMUX_HOST_PLATFORM-gfortran
	export FCFLAGS=""

	# Explicitly define __BIONIC__ and __ANDROID__API__
	CFLAGS+=" -D__BIONIC__ -D__ANDROID_API__=$TERMUX_PKG_API_LEVEL"
	CPPFLAGS+=" -D__BIONIC__ -D__ANDROID_API__=$TERMUX_PKG_API_LEVEL"
	CXXFLAGS+=" -D__BIONIC__ -D__ANDROID_API__=$TERMUX_PKG_API_LEVEL"
	FCFLAGS+=" -D__ANDROID_API__=$TERMUX_PKG_API_LEVEL"
}

_setup_toolchain_ndk_r17c() {
	GCC_STANDALONE_TOOLCHAIN="$TERMUX_COMMON_CACHEDIR/android-r17c-api-${TERMUX_PKG_API_LEVEL}-$TERMUX_HOST_PLATFORM-gcc-4.9"
	GCC_STANDALONE_TOOLCHAIN+="-v0"

	_setup_toolchain_ndk_r17c_envs

	if [ "$TERMUX_ON_DEVICE_BUILD" = "true" ] || [ -d $GCC_STANDALONE_TOOLCHAIN ]; then
		return
	fi

	local GCC_STANDALONE_TOOLCHAIN_TMP="$GCC_STANDALONE_TOOLCHAIN"-tmp

	# Setup a standalone toolchain
	_setup_standalone_toolchain_ndk_r17c "$GCC_STANDALONE_TOOLCHAIN_TMP"

	mv $GCC_STANDALONE_TOOLCHAIN_TMP $GCC_STANDALONE_TOOLCHAIN
}

_setup_standalone_toolchain_ndk_r17c_newer_gcc() {
	if [ "$TERMUX_ON_DEVICE_BUILD" = "true" ]; then
		termux_error_exit "NDK toolchain r17c with newer gcc is not available for on-device builds."
	fi

	# XXX: Install some build dependencies
	# XXX: So should TUR use a custom builder image?
	env -i PATH="$PATH" sudo apt update
	env -i PATH="$PATH" sudo apt install -y libgmp-dev libmpfr-dev libmpc-dev zlib1g-dev libisl-dev libtinfo5 libncurses5

	local GCC_VERSION="$1"
	local GCC_TOOLCHAIN_REVISION="$2"
	local GCC_PREBUILT_SHA256="$3"
	local GCC_TOOLCHAIN_VERSION="$4"

	local GCC_PREBUILT_URL=https://github.com/termux-user-repository/ndk-toolchain-gcc-${GCC_VERSION%%.*}/releases/download/v$GCC_VERSION-r$GCC_TOOLCHAIN_REVISION/gcc-$GCC_VERSION-$TERMUX_ARCH.tar.bz2
	local GCC_PREBUILT_FILE=$TERMUX_COMMON_CACHEDIR/gcc-$GCC_VERSION-r$GCC_TOOLCHAIN_REVISION-$TERMUX_ARCH.tar.bz2
	termux_download $GCC_PREBUILT_URL $GCC_PREBUILT_FILE $GCC_PREBUILT_SHA256

	GCC_STANDALONE_TOOLCHAIN="$TERMUX_COMMON_CACHEDIR/android-r17c-api-${TERMUX_PKG_API_LEVEL}-$TERMUX_HOST_PLATFORM-gcc-$GCC_VERSION-r$GCC_TOOLCHAIN_REVISION-v$GCC_TOOLCHAIN_VERSION"

	if ! [ -d $GCC_STANDALONE_TOOLCHAIN ]; then
		local GCC_STANDALONE_TOOLCHAIN_TMP="$GCC_STANDALONE_TOOLCHAIN"-tmp

		# Setup a standalone toolchain
		_setup_standalone_toolchain_ndk_r17c "$GCC_STANDALONE_TOOLCHAIN_TMP"

		# Merge toolchain
		tar -jxf $GCC_PREBUILT_FILE -C $TERMUX_PKG_TMPDIR
		rm -rf $TERMUX_PKG_TMPDIR/gcc-$GCC_VERSION-$TERMUX_ARCH/sysroot
		cp -R $TERMUX_PKG_TMPDIR/gcc-$GCC_VERSION-$TERMUX_ARCH/* $GCC_STANDALONE_TOOLCHAIN_TMP/
		rm -rf $TERMUX_PKG_TMPDIR/gcc-$GCC_VERSION-$TERMUX_ARCH
		mv $GCC_STANDALONE_TOOLCHAIN_TMP/include/c++/4.9.x $GCC_STANDALONE_TOOLCHAIN_TMP/include/c++/$GCC_VERSION
		cp -R $GCC_STANDALONE_TOOLCHAIN_TMP/sysroot/usr/include/$TERMUX_HOST_PLATFORM/* $GCC_STANDALONE_TOOLCHAIN_TMP/sysroot/usr/include/

		# Remove the older version of clang toolchain
		rm -rf $GCC_STANDALONE_TOOLCHAIN_TMP/bin/clang*
		rm -rf $GCC_STANDALONE_TOOLCHAIN_TMP/bin/llvm*
		rm -rf $GCC_STANDALONE_TOOLCHAIN_TMP/bin/$TERMUX_HOST_PLATFORM-clang*
		rm -rf $GCC_STANDALONE_TOOLCHAIN_TMP/bin/$TERMUX_HOST_PLATFORM-gcc-4.9*

		mv $GCC_STANDALONE_TOOLCHAIN_TMP $GCC_STANDALONE_TOOLCHAIN
	fi
}

_setup_toolchain_ndk_r17c_gcc_11() {
	local GCC_VERSION=11.3.0
	local GCC_TOOLCHAIN_REVISION=1
	local GCC_TOOLCHAIN_VERSION=0
	local GCC_PREBUILT_SHA256

	if [ "$TERMUX_ARCH" == "aarch64" ]; then
		GCC_PREBUILT_SHA256=dafb382041adb5967ad86026aea3d99469ee021d2d5c903e95e318ab6fda365c
	elif [ "$TERMUX_ARCH" == "arm" ]; then
		GCC_PREBUILT_SHA256=9ff8fe2e746a958335400e7e9ccd4bf54b5da33850910938c612e4e58e25ea94
	elif [ "$TERMUX_ARCH" == "x86_64" ]; then
		GCC_PREBUILT_SHA256=7844ec3bbbc3280751e945582b5d23f0079d34bddf8babcbbe964bbab214ee11
	elif [ "$TERMUX_ARCH" == "i686" ]; then
		GCC_PREBUILT_SHA256=d736ff45cef72c64c5d7f1a3cdc602d82dfbc753ced1633ab9f6fd48e9579908
	fi

	_setup_standalone_toolchain_ndk_r17c_newer_gcc "$GCC_VERSION" "$GCC_TOOLCHAIN_REVISION" "$GCC_PREBUILT_SHA256" "$GCC_TOOLCHAIN_VERSION"
	_setup_toolchain_ndk_r17c_envs_with_fc
}

_setup_toolchain_ndk_r17c_gcc_10() {
	local GCC_VERSION=10.4.0
	local GCC_TOOLCHAIN_REVISION=0
	local GCC_TOOLCHAIN_VERSION=0
	local GCC_PREBUILT_SHA256

	if [ "$TERMUX_ARCH" == "aarch64" ]; then
		GCC_PREBUILT_SHA256=db44b64c08456b5ec690c86a090c564961ebc7f7c01dd4f1a17898be4e1e555f
	elif [ "$TERMUX_ARCH" == "arm" ]; then
		GCC_PREBUILT_SHA256=6dc2f2762b12784f5f88f3f1d4bb3f724d282a39d680cfad03d7c1d53f041570
	elif [ "$TERMUX_ARCH" == "x86_64" ]; then
		GCC_PREBUILT_SHA256=6a4c26c0a2b5c4813f082d67e3dc993d134d13191dba5de98b83bb0fff886589
	elif [ "$TERMUX_ARCH" == "i686" ]; then
		GCC_PREBUILT_SHA256=d8ca463c925d456e92c8a1d0d9c39521abe318e5c1e73e92a6fc7c2dae05b8ec
	fi

	_setup_standalone_toolchain_ndk_r17c_newer_gcc "$GCC_VERSION" "$GCC_TOOLCHAIN_REVISION" "$GCC_PREBUILT_SHA256" "$GCC_TOOLCHAIN_VERSION"
	_setup_toolchain_ndk_r17c_envs_with_fc
}

_setup_toolchain_ndk_r17c_gcc_9() {
	local GCC_VERSION=9.5.0
	local GCC_TOOLCHAIN_REVISION=0
	local GCC_TOOLCHAIN_VERSION=0
	local GCC_PREBUILT_SHA256

	if [ "$TERMUX_ARCH" == "aarch64" ]; then
		GCC_PREBUILT_SHA256=fb1dbedf4df7bbf2241c1d630004818c585c993a930a190a1e0ce407e1ae5526
	elif [ "$TERMUX_ARCH" == "arm" ]; then
		GCC_PREBUILT_SHA256=7f82cda41b75836f599e31b3e8130093ef4098bbbe5d663e9058c05c98915fab
	elif [ "$TERMUX_ARCH" == "x86_64" ]; then
		GCC_PREBUILT_SHA256=fb103e232166f07fbc48fa7cd1dcba828f6a8b9a96e5990906eb2039cd758fbe
	elif [ "$TERMUX_ARCH" == "i686" ]; then
		GCC_PREBUILT_SHA256=05c5ee59e6ef3ac5b9a30329cfc6a270313ba608c9ef801784abed02c4f2fdfc
	fi

	_setup_standalone_toolchain_ndk_r17c_newer_gcc "$GCC_VERSION" "$GCC_TOOLCHAIN_REVISION" "$GCC_PREBUILT_SHA256" "$GCC_TOOLCHAIN_VERSION"
	_setup_toolchain_ndk_r17c_envs_with_fc
}

_setup_toolchain_ndk_r17c_gcc_12() {
	local GCC_VERSION=12.1.0
	local GCC_TOOLCHAIN_REVISION=0
	local GCC_TOOLCHAIN_VERSION=0
	local GCC_PREBUILT_SHA256

	if [ "$TERMUX_ARCH" == "aarch64" ]; then
		GCC_PREBUILT_SHA256=b4efd7e65344805464f87fbee9effe44ad6224faf6f9fd20289598c00d0c1cfd
	elif [ "$TERMUX_ARCH" == "arm" ]; then
		GCC_PREBUILT_SHA256=e4b91ed417bdf6d32371d663ed3b5115e895a928259e51e4c9fd24acb142ec84
	elif [ "$TERMUX_ARCH" == "x86_64" ]; then
		GCC_PREBUILT_SHA256=bf807564d80ac7a1da4bca4f86cd6ed1f60dc0234753a5052329b35655d7b81b
	elif [ "$TERMUX_ARCH" == "i686" ]; then
		GCC_PREBUILT_SHA256=2694628eee5e5a8097364cceef71502e21a4ad53b10154c69e7d0f7689583dba
	fi

	_setup_standalone_toolchain_ndk_r17c_newer_gcc "$GCC_VERSION" "$GCC_TOOLCHAIN_REVISION" "$GCC_PREBUILT_SHA256" "$GCC_TOOLCHAIN_VERSION"
	_setup_toolchain_ndk_r17c_envs_with_fc
}

_setup_toolchain_ndk_with_gfortran_11() {
	local GCC_VERSION=11.3.0
	local GCC_TOOLCHAIN_REVISION=0
	local GCC_TOOLCHAIN_VERSION=0
	local GCC_PREBUILT_SHA256

	if [ "$TERMUX_ARCH" == "aarch64" ]; then
		GCC_PREBUILT_SHA256=b1b7bc20f4112236c7962e031ae0b648939424b80342f0cd3e7a11266c147e30
	elif [ "$TERMUX_ARCH" == "arm" ]; then
		GCC_PREBUILT_SHA256=b93b93ef89304d86a1714cfb2cb22b7728a709efec12e6536568fb64e6bb5116
	elif [ "$TERMUX_ARCH" == "x86_64" ]; then
		GCC_PREBUILT_SHA256=b5de13b6fdd03b42e0f6292f4f51aaad8a643cb1fe7f2014d26026009317d6ed
	elif [ "$TERMUX_ARCH" == "i686" ]; then
		GCC_PREBUILT_SHA256=4e03c55dd3956e2b3edbe576d4c346435a582b053dd8703992621bddd5bb408b
	fi

	_setup_standalone_toolchain_ndk_r17c_newer_gcc "$GCC_VERSION" "$GCC_TOOLCHAIN_REVISION" "$GCC_PREBUILT_SHA256" "$GCC_TOOLCHAIN_VERSION"

	# Set FC
	export FC=$TERMUX_HOST_PLATFORM-gfortran
	export FCFLAGS=""

	# Explicitly define __BIONIC__ and __ANDROID__API__
	CFLAGS+=" -D__BIONIC__ -D__ANDROID_API__=$TERMUX_PKG_API_LEVEL"
	CPPFLAGS+=" -D__BIONIC__ -D__ANDROID_API__=$TERMUX_PKG_API_LEVEL"
	CXXFLAGS+=" -D__BIONIC__ -D__ANDROID_API__=$TERMUX_PKG_API_LEVEL"
	FCFLAGS+=" -D__ANDROID_API__=$TERMUX_PKG_API_LEVEL"

	export PATH="$PATH:$GCC_STANDALONE_TOOLCHAIN/bin"
}

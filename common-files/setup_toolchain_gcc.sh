_setup_toolchain_gcc_envs() {
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
		LDFLAGS+=" -Wl,-rpath-link=$TERMUX_PREFIX/lib"
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

_setup_toolchain_gcc_envs_with_fc() {
	_setup_toolchain_gcc_envs

	# Set FC
	export FC=$TERMUX_HOST_PLATFORM-gfortran
	export FCFLAGS=""

	# Explicitly define __BIONIC__ and __ANDROID__API__
	CFLAGS+=" -D__BIONIC__ -D__ANDROID_API__=$TERMUX_PKG_API_LEVEL"
	CPPFLAGS+=" -D__BIONIC__ -D__ANDROID_API__=$TERMUX_PKG_API_LEVEL"
	CXXFLAGS+=" -D__BIONIC__ -D__ANDROID_API__=$TERMUX_PKG_API_LEVEL"
	FCFLAGS+=" -D__ANDROID_API__=$TERMUX_PKG_API_LEVEL"
}

_override_configure_cmake_for_gcc() {
	termux_step_configure_cmake() {
		if [ "$TERMUX_CMAKE_BUILD" = Ninja ]; then
			MAKE_PROGRAM_PATH=$(command -v ninja)
		else
			MAKE_PROGRAM_PATH=$(command -v make)
		fi
		BUILD_TYPE=Release
		test "$TERMUX_DEBUG_BUILD" == "true" && BUILD_TYPE=Debug
		CMAKE_PROC=$TERMUX_ARCH
		test $CMAKE_PROC == "arm" && CMAKE_PROC='armv7-a'

		local CMAKE_ADDITIONAL_ARGS=()
		if [ "$TERMUX_ON_DEVICE_BUILD" = "false" ]; then
			CXXFLAGS+=" -D__ANDROID_API__=$TERMUX_PKG_API_LEVEL"
			CFLAGS+=" -D__ANDROID_API__=$TERMUX_PKG_API_LEVEL"
			LDFLAGS+=" -D__ANDROID_API__=$TERMUX_PKG_API_LEVEL"

			CMAKE_ADDITIONAL_ARGS+=("-DCMAKE_CROSSCOMPILING=True")
			CMAKE_ADDITIONAL_ARGS+=("-DCMAKE_LINKER=$GCC_STANDALONE_TOOLCHAIN/bin/$LD $LDFLAGS")
			CMAKE_ADDITIONAL_ARGS+=("-DCMAKE_SYSTEM_NAME=Android")
			CMAKE_ADDITIONAL_ARGS+=("-DCMAKE_SYSTEM_VERSION=$TERMUX_PKG_API_LEVEL")
			CMAKE_ADDITIONAL_ARGS+=("-DCMAKE_SYSTEM_PROCESSOR=$CMAKE_PROC")
			CMAKE_ADDITIONAL_ARGS+=("-DCMAKE_ANDROID_STANDALONE_TOOLCHAIN=$GCC_STANDALONE_TOOLCHAIN")
		else
			CMAKE_ADDITIONAL_ARGS+=("-DCMAKE_LINKER=$(command -v $LD) $LDFLAGS")
		fi

		# XXX: CMAKE_{AR,RANLIB} needed for at least jsoncpp build to not
		# pick up cross compiled binutils tool in $TERMUX_PREFIX/bin:
		cmake -G "$TERMUX_CMAKE_BUILD" "$TERMUX_PKG_SRCDIR" \
			-DCMAKE_AR="$(command -v $AR)" \
			-DCMAKE_UNAME="$(command -v uname)" \
			-DCMAKE_RANLIB="$(command -v $RANLIB)" \
			-DCMAKE_STRIP="$(command -v $STRIP)" \
			-DCMAKE_BUILD_TYPE=$BUILD_TYPE \
			-DCMAKE_C_FLAGS="$CFLAGS $CPPFLAGS" \
			-DCMAKE_CXX_FLAGS="$CXXFLAGS $CPPFLAGS" \
			-DCMAKE_FIND_ROOT_PATH=$TERMUX_PREFIX \
			-DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER \
			-DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY \
			-DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY \
			-DCMAKE_INSTALL_PREFIX=$TERMUX_PREFIX \
			-DCMAKE_INSTALL_LIBDIR=$TERMUX_PREFIX/lib \
			-DCMAKE_MAKE_PROGRAM=$MAKE_PROGRAM_PATH \
			-DCMAKE_SKIP_INSTALL_RPATH=ON \
			-DCMAKE_USE_SYSTEM_LIBRARIES=True \
			-DDOXYGEN_EXECUTABLE= \
			-DBUILD_TESTING=OFF \
			"${CMAKE_ADDITIONAL_ARGS[@]}" \
			$TERMUX_PKG_EXTRA_CONFIGURE_ARGS
	}
}

_setup_standalone_toolchain_current_ndk_newer_gcc() {
	if [ "$TERMUX_ON_DEVICE_BUILD" = "true" ]; then
		termux_error_exit "NDK toolchain with newer gcc is not available for on-device builds."
	fi

	# XXX: Install some build dependencies
	# XXX: So should TUR use a custom builder image?
	env -i PATH="$PATH" sudo apt update
	env -i PATH="$PATH" sudo apt install -y libgmp-dev libmpfr-dev libmpc-dev zlib1g-dev libisl-dev

	local GCC_VERSION="$1"
	local GCC_TOOLCHAIN_REVISION="$2"
	local GCC_PREBUILT_SHA256="$3"
	local GCC_TOOLCHAIN_VERSION="$4"
	local GCC_MAJOR_VERSION="${GCC_VERSION%%.*}"
	local SYSROOT_REVISION="$(TERMUX_PKG_REVISION=0; . $TERMUX_SCRIPTDIR/tur/ndk-sysroot-gcc-compact/build.sh; echo $TERMUX_PKG_REVISION)"

	local GCC_PREBUILT_URL=https://github.com/termux-user-repository/ndk-toolchain-gcc-$GCC_MAJOR_VERSION/releases/download/v$GCC_VERSION-r$GCC_TOOLCHAIN_REVISION/gcc-$GCC_VERSION-$TERMUX_ARCH.tar.bz2
	local GCC_PREBUILT_FILE=$TERMUX_COMMON_CACHEDIR/gcc-$GCC_VERSION-r$GCC_TOOLCHAIN_REVISION-$TERMUX_ARCH.tar.bz2
	termux_download $GCC_PREBUILT_URL $GCC_PREBUILT_FILE $GCC_PREBUILT_SHA256

	GCC_STANDALONE_TOOLCHAIN="$TERMUX_COMMON_CACHEDIR/android-r$TERMUX_NDK_VERSION-api-${TERMUX_PKG_API_LEVEL}-$TERMUX_HOST_PLATFORM-gcc-$GCC_VERSION-r$GCC_TOOLCHAIN_REVISION-v$GCC_TOOLCHAIN_VERSION-sysroot-r$SYSROOT_REVISION"

	if ! [ -d $GCC_STANDALONE_TOOLCHAIN ]; then
		local GCC_STANDALONE_TOOLCHAIN_TMP="$GCC_STANDALONE_TOOLCHAIN"-tmp

		# Setup a standalone toolchain
		rm -rf $GCC_STANDALONE_TOOLCHAIN_TMP
		mkdir -p $GCC_STANDALONE_TOOLCHAIN_TMP
		tar -jxf $GCC_PREBUILT_FILE -C $TERMUX_PKG_TMPDIR
		rm -rf $TERMUX_PKG_TMPDIR/gcc-$GCC_VERSION-$TERMUX_ARCH/sysroot
		cp -R $TERMUX_PKG_TMPDIR/gcc-$GCC_VERSION-$TERMUX_ARCH/* $GCC_STANDALONE_TOOLCHAIN_TMP/
		rm -rf $TERMUX_PKG_TMPDIR/gcc-$GCC_VERSION-$TERMUX_ARCH
		mkdir -p $GCC_STANDALONE_TOOLCHAIN_TMP/sysroot/usr/include $GCC_STANDALONE_TOOLCHAIN_TMP/sysroot/usr/lib
		cp -R $TERMUX_STANDALONE_TOOLCHAIN/sysroot/usr/include/* $GCC_STANDALONE_TOOLCHAIN_TMP/sysroot/usr/include
		for f in $(find "$TERMUX_SCRIPTDIR/tur/ndk-sysroot-gcc-compact/" -maxdepth 1 -type f -name *.patch | sort); do
			echo "Applying patch: $(basename $f)"
			patch -d "$GCC_STANDALONE_TOOLCHAIN_TMP/sysroot/usr/include/" -p8 < "$f";
		done
		cp -R $TERMUX_STANDALONE_TOOLCHAIN/sysroot/usr/lib/$TERMUX_HOST_PLATFORM/$TERMUX_PKG_API_LEVEL/* \
			$GCC_STANDALONE_TOOLCHAIN_TMP/sysroot/usr/lib/
		# Use libc++_shared as libstdc++
		cp "$TERMUX_STANDALONE_TOOLCHAIN/sysroot/usr/lib/$TERMUX_HOST_PLATFORM/libc++_shared.so" $GCC_STANDALONE_TOOLCHAIN_TMP/sysroot/usr/lib/
		cp "$TERMUX_STANDALONE_TOOLCHAIN/sysroot/usr/lib/$TERMUX_HOST_PLATFORM/libc++_static.a" $GCC_STANDALONE_TOOLCHAIN_TMP/sysroot/usr/lib/
		cp "$TERMUX_STANDALONE_TOOLCHAIN/sysroot/usr/lib/$TERMUX_HOST_PLATFORM/libc++abi.a" $GCC_STANDALONE_TOOLCHAIN_TMP/sysroot/usr/lib/
		echo "INPUT(-lc++_shared)" > $GCC_STANDALONE_TOOLCHAIN_TMP/$TERMUX_HOST_PLATFORM/lib/libstdc++.so
		echo "INPUT(-lc++_static -lc++abi)" > $GCC_STANDALONE_TOOLCHAIN_TMP/$TERMUX_HOST_PLATFORM/lib/libstdc++.a
		mkdir -p $GCC_STANDALONE_TOOLCHAIN_TMP/include/c++/$GCC_VERSION
		# Remove fix-includes
		rm -rf $GCC_STANDALONE_TOOLCHAIN_TMP/lib/gcc/$TERMUX_HOST_PLATFORM/$GCC_VERSION/include-fixed
		cp -R $GCC_STANDALONE_TOOLCHAIN_TMP/sysroot/usr/include/c++/v1/* $GCC_STANDALONE_TOOLCHAIN_TMP/include/c++/$GCC_VERSION
		# See https://github.com/android/ndk/issues/215#issuecomment-524293090
		sed -i "s/include_next <stddef.h>/include <stddef.h>/" $GCC_STANDALONE_TOOLCHAIN_TMP/include/c++/$GCC_VERSION/cstddef
		cp -R $GCC_STANDALONE_TOOLCHAIN_TMP/sysroot/usr/include/$TERMUX_HOST_PLATFORM/* $GCC_STANDALONE_TOOLCHAIN_TMP/sysroot/usr/include/
		# Fix the libdir in libgfortran.la file
		if [ "$TERMUX_ARCH" = "x86_64" ]; then
			local _orig_prefix="'/home/runner/work/ndk-toolchain-gcc-$GCC_MAJOR_VERSION/ndk-toolchain-gcc-$GCC_MAJOR_VERSION/tmp/newer-toolchain/$TERMUX_HOST_PLATFORM/lib/../lib64'/libquadmath.la"
			local _targ_prefix="'$GCC_STANDALONE_TOOLCHAIN/$TERMUX_HOST_PLATFORM/lib/../lib64'/libquadmath.la"
			sed -i "s|$_orig_prefix|$_targ_prefix|g" $GCC_STANDALONE_TOOLCHAIN_TMP/$TERMUX_HOST_PLATFORM/lib64/libgfortran.la
		fi
		if [ "$TERMUX_ARCH" = "i686" ]; then
			local _orig_prefix="'/home/runner/work/ndk-toolchain-gcc-$GCC_MAJOR_VERSION/ndk-toolchain-gcc-$GCC_MAJOR_VERSION/tmp/newer-toolchain/$TERMUX_HOST_PLATFORM/lib'/libquadmath.la"
			local _targ_prefix="'$GCC_STANDALONE_TOOLCHAIN/$TERMUX_HOST_PLATFORM/lib'/libquadmath.la"
			sed -i "s|$_orig_prefix|$_targ_prefix|g" $GCC_STANDALONE_TOOLCHAIN_TMP/$TERMUX_HOST_PLATFORM/lib/libgfortran.la
		fi

		mv $GCC_STANDALONE_TOOLCHAIN_TMP $GCC_STANDALONE_TOOLCHAIN
	fi
}

_setup_toolchain_ndk_with_gfortran_11() {
	local GCC_TOOLCHAIN_VERSION=2

    local PREBUILT_GCC_JSON="$TERMUX_SCRIPTDIR/common-files/prebuilt-gcc.json"
	local GCC_VERSION=$(jq -r '.["11"].version' $PREBUILT_GCC_JSON)
	local GCC_TOOLCHAIN_REVISION=$(jq -r '.["11"].revision' $PREBUILT_GCC_JSON)
	local GCC_PREBUILT_SHA256=$(jq -r ".[\"11\"].checksums.$TERMUX_ARCH" $PREBUILT_GCC_JSON)

	_setup_standalone_toolchain_current_ndk_newer_gcc "$GCC_VERSION" "$GCC_TOOLCHAIN_REVISION" "$GCC_PREBUILT_SHA256" "$GCC_TOOLCHAIN_VERSION"

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

_setup_toolchain_ndk_gcc_11() {
	local GCC_TOOLCHAIN_VERSION=2

    local PREBUILT_GCC_JSON="$TERMUX_SCRIPTDIR/common-files/prebuilt-gcc.json"
	local GCC_VERSION=$(jq -r '.["11"].version' $PREBUILT_GCC_JSON)
	local GCC_TOOLCHAIN_REVISION=$(jq -r '.["11"].revision' $PREBUILT_GCC_JSON)
	local GCC_PREBUILT_SHA256=$(jq -r ".[\"11\"].checksums.$TERMUX_ARCH" $PREBUILT_GCC_JSON)

	_setup_standalone_toolchain_current_ndk_newer_gcc "$GCC_VERSION" "$GCC_TOOLCHAIN_REVISION" "$GCC_PREBUILT_SHA256" "$GCC_TOOLCHAIN_VERSION"
	_setup_toolchain_gcc_envs_with_fc
}

_setup_toolchain_ndk_gcc_12() {
	local GCC_TOOLCHAIN_VERSION=2

    local PREBUILT_GCC_JSON="$TERMUX_SCRIPTDIR/common-files/prebuilt-gcc.json"
	local GCC_VERSION=$(jq -r '.["12"].version' $PREBUILT_GCC_JSON)
	local GCC_TOOLCHAIN_REVISION=$(jq -r '.["12"].revision' $PREBUILT_GCC_JSON)
	local GCC_PREBUILT_SHA256=$(jq -r ".[\"12\"].checksums.$TERMUX_ARCH" $PREBUILT_GCC_JSON)

	_setup_standalone_toolchain_current_ndk_newer_gcc "$GCC_VERSION" "$GCC_TOOLCHAIN_REVISION" "$GCC_PREBUILT_SHA256" "$GCC_TOOLCHAIN_VERSION"
	_setup_toolchain_gcc_envs_with_fc
}

_setup_toolchain_ndk_gcc_13() {
	local GCC_TOOLCHAIN_VERSION=2

    local PREBUILT_GCC_JSON="$TERMUX_SCRIPTDIR/common-files/prebuilt-gcc.json"
	local GCC_VERSION=$(jq -r '.["13"].version' $PREBUILT_GCC_JSON)
	local GCC_TOOLCHAIN_REVISION=$(jq -r '.["13"].revision' $PREBUILT_GCC_JSON)
	local GCC_PREBUILT_SHA256=$(jq -r ".[\"13\"].checksums.$TERMUX_ARCH" $PREBUILT_GCC_JSON)

	_setup_standalone_toolchain_current_ndk_newer_gcc "$GCC_VERSION" "$GCC_TOOLCHAIN_REVISION" "$GCC_PREBUILT_SHA256" "$GCC_TOOLCHAIN_VERSION"
	_setup_toolchain_gcc_envs_with_fc
}

_setup_toolchain_ndk_gcc_14() {
	local GCC_TOOLCHAIN_VERSION=0

    local PREBUILT_GCC_JSON="$TERMUX_SCRIPTDIR/common-files/prebuilt-gcc.json"
	local GCC_VERSION=$(jq -r '.["14"].version' $PREBUILT_GCC_JSON)
	local GCC_TOOLCHAIN_REVISION=$(jq -r '.["14"].revision' $PREBUILT_GCC_JSON)
	local GCC_PREBUILT_SHA256=$(jq -r ".[\"14\"].checksums.$TERMUX_ARCH" $PREBUILT_GCC_JSON)

	_setup_standalone_toolchain_current_ndk_newer_gcc "$GCC_VERSION" "$GCC_TOOLCHAIN_REVISION" "$GCC_PREBUILT_SHA256" "$GCC_TOOLCHAIN_VERSION"
	_setup_toolchain_gcc_envs_with_fc
}

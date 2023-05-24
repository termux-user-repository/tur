case "$TERMUX_ARCH" in
	aarch64|arm)
	TUR_MULTILIB_ARCH="arm"
	TUR_MULTILIB_ARCH_TRIPLE="arm-linux-androideabi"
	;;
	x86_64|i686)
	TUR_MULTILIB_ARCH="i686"
	TUR_MULTILIB_ARCH_TRIPLE="i686-linux-android"
	;;
	*)
	termux_error_exit "Invalid arch: $TERMUX_ARCH"
	;;
esac

_setup_multilib_toolchain() {
	export CFLAGS=""
	export CPPFLAGS=""
	export LDFLAGS="-L${TERMUX_PREFIX}/$TUR_MULTILIB_ARCH_TRIPLE/lib"

	export AS=$TUR_MULTILIB_ARCH_TRIPLE-clang
	export CC=$TUR_MULTILIB_ARCH_TRIPLE-clang
	export CXX=$TUR_MULTILIB_ARCH_TRIPLE-clang++
	export CPP=$TUR_MULTILIB_ARCH_TRIPLE-cpp
	export LD=ld.lld
	export AR=llvm-ar
	export OBJCOPY=llvm-objcopy
	export OBJDUMP=llvm-objdump
	export RANLIB=llvm-ranlib
	export READELF=llvm-readelf
	export STRIP=llvm-strip
	export NM=llvm-nm

	if [ "$TERMUX_ON_DEVICE_BUILD" = "false" ]; then
		export CC_FOR_BUILD=gcc
		export PKG_CONFIG=$TERMUX_PKG_TMPDIR/multilib-toolchain-bin/pkg-config
		export PKGCONFIG=$PKG_CONFIG
		LDFLAGS+=" -Wl,-rpath=$TERMUX_PREFIX/$TUR_MULTILIB_ARCH_TRIPLE/lib"
	else
		export CC_FOR_BUILD=$CC
		# Some build scripts use environment variable 'PKG_CONFIG', so
		# using this for on-device builds too.
		export PKG_CONFIG=pkg-config
	fi
	export PKG_CONFIG_LIBDIR="$TERMUX_PREFIX/$TUR_MULTILIB_ARCH_TRIPLE/lib/pkgconfig:$TERMUX_PREFIX/share/pkgconfig"

	# Create a pkg-config wrapper. We use path to host pkg-config to
	# avoid picking up a cross-compiled pkg-config later on.
	mkdir -p $TERMUX_PKG_TMPDIR/multilib-toolchain-bin

	cat > $TERMUX_PKG_TMPDIR/multilib-toolchain-bin/pkg-config <<-HERE
		#!/bin/sh
		export PKG_CONFIG_DIR=
		export PKG_CONFIG_LIBDIR=$PKG_CONFIG_LIBDIR
		exec /usr/bin/pkg-config "\$@"
	HERE
	chmod +x $TERMUX_PKG_TMPDIR/multilib-toolchain-bin/pkg-config

	if [ "$TUR_MULTILIB_ARCH" = "arm" ]; then
		# https://developer.android.com/ndk/guides/standalone_toolchain.html#abi_compatibility:
		# "We recommend using the -mthumb compiler flag to force the generation of 16-bit Thumb-2 instructions".
		# With r13 of the ndk ruby 2.4.0 segfaults when built on arm with clang without -mthumb.
		CFLAGS+=" -march=armv7-a -mfpu=neon -mfloat-abi=softfp -mthumb"
		LDFLAGS+=" -march=armv7-a"
	elif [ "$TUR_MULTILIB_ARCH" = "i686" ]; then
		# From $NDK/docs/CPU-ARCH-ABIS.html:
		CFLAGS+=" -march=i686 -msse3 -mstackrealign -mfpmath=sse"
		# i686 seem to explicitly require -fPIC, see
		# https://github.com/termux/termux-packages/issues/7215#issuecomment-906154438
		CFLAGS+=" -fPIC"
	else
		termux_error_exit "Invalid arch '$TUR_MULTILIB_ARCH' - support arches are 'arm', 'i686'"
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
	CPPFLAGS+=" -I${TERMUX_PREFIX}/$TUR_MULTILIB_ARCH_TRIPLE/include"

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

TERMUX_PKG_HOMEPAGE=https://github.com/AdaCore/xmlada
TERMUX_PKG_DESCRIPTION="The XML/Ada toolkit"
TERMUX_PKG_LICENSE="custom"
TERMUX_PKG_LICENSE_FILE="COPYING3, COPYING.RUNTIME"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="23.0.0"
TERMUX_PKG_SRCURL=https://github.com/AdaCore/xmlada/archive/refs/tags/v$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=66245a68f2e391c8dc8dc50d6d5f109eb3b371e261d095d2002dff3927dd5253
TERMUX_PKG_BUILD_DEPENDS="gcc-11, gcc-default-11, gprbuild-bootstrap, gnat"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_NO_STATICSPLIT=true
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--enable-shared=yes
"

termux_step_pre_configure() {
	if [ "${TERMUX_ON_DEVICE_BUILD}" = false ]; then
		termux_error_exit "This package doesn't support cross-compiling."
	fi

	export GNATMAKE="gnatmake-11"

	CFLAGS="${CFLAGS/-Oz/-Os}"
	CXXFLAGS="${CXXFLAGS/-Oz/-Os}"
	LDFLAGS="${LDFLAGS/-static-openmp/''}"

	CROSS_PREFIX=$TERMUX_ARCH-linux-android
	if [ "$TERMUX_ARCH" == "arm" ]; then
		CROSS_PREFIX=arm-linux-androideabi
	fi

	export AR=$CROSS_PREFIX-ar
	export AS=$CROSS_PREFIX-as
	export LD=$CROSS_PREFIX-ld
	export NM=$CROSS_PREFIX-nm
	export CC=$CROSS_PREFIX-gcc-11
	export FC=$CROSS_PREFIX-gfortran-11
	export CXX=$CROSS_PREFIX-g++-11
	unset CPP CXXCPP STRINGS
	export STRIP=$CROSS_PREFIX-strip
	export RANLIB=$CROSS_PREFIX-ranlib

	export PATH="$PREFIX/opt/gprbuild-bootstrap/bin:$PATH"

	# FIXME: Build machine is not properly guessed?
	TERMUX_PKG_EXTRA_CONFIGURE_ARGS+="
--build=$TERMUX_HOST_PLATFORM
--host=$TERMUX_HOST_PLATFORM
--target=$TERMUX_HOST_PLATFORM
"
}

termux_step_make() {
	make GPRBUILD_OPTIONS=-vh
}

TERMUX_PKG_HOMEPAGE=https://github.com/AdaCore/gprbuild
TERMUX_PKG_DESCRIPTION="An advanced build system designed to help automate the construction of multi-language systems"
TERMUX_PKG_LICENSE="custom"
TERMUX_PKG_LICENSE_FILE="COPYING3, COPYING.RUNTIME"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="25.0.0"
TERMUX_PKG_SRCURL=https://github.com/AdaCore/gprbuild/archive/refs/tags/v$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=d12f94c1ec0b6e219f6b162f71f57129d22426e7798092f5f85b9ec2cc818bf1
TERMUX_PKG_DEPENDS="gcc-11, gcc-default-11, gnat, gprconfig-kb"
TERMUX_PKG_BUILD_DEPENDS="gprbuild-bootstrap, xmlada"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	if [ "${TERMUX_ON_DEVICE_BUILD}" = false ]; then
		termux_error_exit "This package doesn't support cross-compiling."
	fi
}

termux_step_configure() {
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
	make LIBRARY_TYPE=relocatable all
}

termux_step_make_install() {
	make LIBRARY_TYPE=relocatable install
}

termux_step_post_make_install() {
	rm -f $TERMUX_PREFIX/doinstall
}

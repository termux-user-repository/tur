TERMUX_PKG_HOMEPAGE=https://www.r-project.org/
TERMUX_PKG_DESCRIPTION="A free software environment for statistical computing and graphics"
TERMUX_PKG_LICENSE="GPL-2.0-or-later, LGPL-2.1"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION=4.5.2
TERMUX_PKG_SRCURL=https://cran.r-project.org/src/base/R-${TERMUX_PKG_VERSION::1}/R-$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=0d71ff7106ec69cd7c67e1e95ed1a3cee355880931f2eb78c530014a9e379f20
TERMUX_PKG_DEPENDS="libandroid-glob, libiconv, libbz2, libcurl, liblzma, pcre2, readline, zlib"
TERMUX_PKG_BUILD_DEPENDS="binutils, gcc-15, openjdk-21, which"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
ac_cv_have_decl_wctrans=yes
--with-x=no
--enable-R-shlib
--with-readline=yes
"
# prevents 'duping jobs pipe: Bad file descriptor.  Stop.''
TERMUX_PKG_MAKE_PROCESSES=1

termux_step_pre_configure() {
	if [ "${TERMUX_ON_DEVICE_BUILD}" = false ]; then
		termux_error_exit "This package doesn't support cross-compiling."
	fi

	CFLAGS="${CFLAGS/-Oz/-O0}"
	CXXFLAGS="${CXXFLAGS/-Oz/-O0}"
	LDFLAGS="${LDFLAGS/-static-openmp/''}"
	LDFLAGS+=" -landroid-glob"
	export JAVA_HOME=$TERMUX_PREFIX/opt/openjdk-21

	CROSS_PREFIX=$TERMUX_ARCH-linux-android
	if [ "$TERMUX_ARCH" == "arm" ]; then
		CROSS_PREFIX=arm-linux-androideabi
	fi

	export AR=$CROSS_PREFIX-ar
	export AS=$CROSS_PREFIX-as
	export LD=$CROSS_PREFIX-ld
	export NM=$CROSS_PREFIX-nm
	export CC=$CROSS_PREFIX-gcc-15
	export FC=$CROSS_PREFIX-gfortran-15
	export CXX=$CROSS_PREFIX-g++-15
	unset CPP CXXCPP STRINGS
	export STRIP=$CROSS_PREFIX-strip
	export RANLIB=$CROSS_PREFIX-ranlib

	if [ "$TERMUX_ARCH" == "arm" ]; then
		export MAKEFLAGS="-j1 --jobserver-style=pipe"
	fi
}

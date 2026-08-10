TERMUX_PKG_HOMEPAGE=https://github.com/AdaCore/gprbuild
TERMUX_PKG_DESCRIPTION="An advanced build system designed to help automate the construction of multi-language systems (Bootstrap Version)"
TERMUX_PKG_LICENSE="custom"
TERMUX_PKG_LICENSE_FILE="COPYING3, COPYING.RUNTIME"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="25.0.0"
TERMUX_PKG_SRCURL=https://github.com/AdaCore/gprbuild/archive/refs/tags/v$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=d12f94c1ec0b6e219f6b162f71f57129d22426e7798092f5f85b9ec2cc818bf1
TERMUX_PKG_BUILD_DEPENDS="gcc-11"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_post_get_source() {
	local _xmlada_srcurl="https://github.com/AdaCore/xmlada/archive/refs/tags/v$TERMUX_PKG_VERSION.tar.gz"
	local _xmlada_sha256="dbb5984a0931311c7a787a679ef4cfaeeedd357474a585dc170140ef2251dcca"
	local _xmlada_path="$TERMUX_PKG_CACHEDIR/xmlada-$(basename $_xmlada_srcurl)"
	local _gprconfig_kb_srcurl="https://github.com/AdaCore/gprconfig_kb/archive/refs/tags/v$TERMUX_PKG_VERSION.tar.gz"
	local _gprconfig_kb_sha256="802e6d38a3b110897924a9c16e143cb86360f2dde94bb5b9144c7c391e37b121"
	local _gprconfig_kb_path="$TERMUX_PKG_CACHEDIR/gprconfig_kb-$(basename $_xmlada_srcurl)"

	termux_download $_xmlada_srcurl $_xmlada_path $_xmlada_sha256
	termux_download $_gprconfig_kb_srcurl $_gprconfig_kb_path $_gprconfig_kb_sha256

	mkdir -p $TERMUX_PKG_SRCDIR/xmlada-src
	tar -xf $_xmlada_path -C $TERMUX_PKG_SRCDIR/xmlada-src --strip-components=1

	mkdir -p $TERMUX_PKG_SRCDIR/gprconfig_kb-src
	tar -xf $_gprconfig_kb_path -C $TERMUX_PKG_SRCDIR/gprconfig_kb-src --strip-components=1
}

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

	CFLAGS="-fPIC $CFLAGS"

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
}

termux_step_make() {
	:
}

termux_step_make_install() {
	./bootstrap.sh \
		--with-xmlada=$TERMUX_PKG_SRCDIR/xmlada-src \
		--with-kb=$TERMUX_PKG_SRCDIR/gprconfig_kb-src \
		--prefix=$PREFIX/opt/gprbuild-bootstrap
}

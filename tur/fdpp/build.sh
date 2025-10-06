TERMUX_PKG_HOMEPAGE=https://github.com/dosemu2/fdpp
TERMUX_PKG_DESCRIPTION="64-bit DOS core"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@stsp"
TERMUX_PKG_VERSION=1.10
TERMUX_PKG_SRCURL=https://github.com/dosemu2/fdpp/archive/refs/tags/${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=fd6e4332ab3756acff10511d7a97af8c6eb231861341f8b4194b22011a8dc749
TERMUX_PKG_BUILD_DEPENDS="nasm-segelf-cross, libelf, thunk-gen-cross"
TERMUX_PKG_DEPENDS="libelf"

termux_step_configure() {
	local _PREFIX_FOR_SEGELF=${TERMUX_PREFIX}/opt/nasm-segelf/cross
	local _PREFIX_FOR_THUNK_GEN=${TERMUX_PREFIX}/opt/thunk-gen/cross
	export PATH="$PATH:$_PREFIX_FOR_SEGELF/bin"
	export PKG_CONFIG_PATH="${_PREFIX_FOR_THUNK_GEN}/share/pkgconfig"
	cd $TERMUX_PKG_BUILDDIR
	$TERMUX_PKG_SRCDIR/configure
}

termux_step_make() {
	make -j $TERMUX_PKG_MAKE_PROCESSES -C $TERMUX_PKG_BUILDDIR prefix=$PREFIX CC=$CC CXX=$CXX
}

termux_step_make_install() {
	make -C $TERMUX_PKG_BUILDDIR install prefix=$PREFIX
}

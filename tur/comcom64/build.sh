TERMUX_PKG_HOMEPAGE=https://github.com/dosemu2/comcom64
TERMUX_PKG_DESCRIPTION="64bit command.com"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@stsp"
TERMUX_PKG_VERSION=0.4
TERMUX_PKG_SRCURL=https://github.com/dosemu2/comcom64/archive/refs/tags/${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=b1b23d65fd14aa78d11b59937a474f9aad21e52999faa7ae80a481184fa35af5
TERMUX_PKG_BUILD_DEPENDS="dj64dev, djstub-cross, thunk-gen-cross"
TERMUX_PKG_DEPENDS="dj64dev"

termux_step_pre_configure() {
	local _PREFIX_FOR_DJSTUB=${TERMUX_PREFIX}/opt/djstub/cross
	local _PREFIX_FOR_THUNK_GEN=${TERMUX_PREFIX}/opt/thunk-gen/cross
	export PATH="$PATH:$_PREFIX_FOR_DJSTUB/bin"
	export PKG_CONFIG_PATH="${_PREFIX_FOR_THUNK_GEN}/share/pkgconfig"
}

termux_step_make_install() {
	make install prefix=$PREFIX
}

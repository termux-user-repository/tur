TERMUX_PKG_HOMEPAGE=https://github.com/stsp/dj64dev
TERMUX_PKG_DESCRIPTION="development suite that allows to cross-build 64-bit programs for DOS"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@stsp"
TERMUX_PKG_VERSION=0.4
TERMUX_PKG_SRCURL=https://github.com/stsp/dj64dev/archive/refs/tags/${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=1ec03bef2f1b028faf727e4be1c30102d46331a366fdaaffc6f2aab4ebcadf4f
TERMUX_PKG_BUILD_DEPENDS="ctags-cross, thunk-gen-cross, libelf, ncurses-utils, pkg-config"
TERMUX_PKG_DEPENDS="pkg-config, libelf"

termux_step_pre_configure() {
	local _PREFIX_FOR_CTAGS=${TERMUX_PREFIX}/opt/ctags/cross
	local _PREFIX_FOR_THUNK_GEN=${TERMUX_PREFIX}/opt/thunk-gen/cross
	export PATH="$PATH:${_PREFIX_FOR_CTAGS}/bin"
	export PKG_CONFIG_PATH="${_PREFIX_FOR_THUNK_GEN}/share/pkgconfig"
	cd $TERMUX_PKG_SRCDIR
	autoreconf -v -i -I m4
}

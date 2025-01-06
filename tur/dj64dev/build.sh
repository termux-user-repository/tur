TERMUX_PKG_HOMEPAGE=https://github.com/stsp/dj64dev
TERMUX_PKG_DESCRIPTION="development suite that allows to cross-build 64-bit programs for DOS"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@stsp"
TERMUX_PKG_VERSION=0.3
TERMUX_PKG_REVISION=2
TERMUX_PKG_SRCURL=https://github.com/stsp/dj64dev/archive/refs/tags/${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=d6cd05e92b1f46f20190a4a0fb8dc5a37f0f4dd29380a35651cb974b6501a975
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_DEPENDS="ctags-cross, thunk-gen-cross, libelf"
TERMUX_PKG_DEPENDS="djstub, thunk-gen, libelf"
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_pre_configure() {
	local _PREFIX_FOR_CTAGS=${TERMUX_PREFIX}/opt/ctags/cross
	local _PREFIX_FOR_THUNK_GEN=${TERMUX_PREFIX}/opt/thunk-gen/cross
	export PATH="$PATH:${_PREFIX_FOR_CTAGS}/bin"
	export PKG_CONFIG_PATH="${_PREFIX_FOR_THUNK_GEN}/share/pkgconfig"
	cd $TERMUX_PKG_SRCDIR
	autoreconf -v -i -I m4
}

termux_step_make() {
	cd $TERMUX_PKG_SRCDIR
	make
}

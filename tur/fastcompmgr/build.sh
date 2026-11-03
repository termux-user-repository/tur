TERMUX_PKG_HOMEPAGE=https://github.com/tycho-kirchner/fastcompmgr
TERMUX_PKG_DESCRIPTION="A fast compositor for X11"
TERMUX_PKG_LICENSE="MIT, HPND"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="0.6.1"
TERMUX_PKG_SRCURL=https://github.com/tycho-kirchner/fastcompmgr/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=b93b5c6ed6926e7c9419e3e620d2bf26a8f106bd55f59474e0d7d6328003192c
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_DEPENDS="libx11, libxcomposite, libxdamage, libxext, libxfixes, libxrender"
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_make_install() {
	install -Dm 755 -t "$TERMUX_PREFIX/bin" fastcompmgr
}

TERMUX_PKG_HOMEPAGE=https://www.blockbench.net
TERMUX_PKG_DESCRIPTION="Low-poly 3D model editor"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="5.2.2"
TERMUX_PKG_SRCURL="https://github.com/JannisX11/blockbench/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=a87d035f8aa62130c8b4ddb686dd0c84492abc16526c44719424adb910eb3f83
TERMUX_PKG_DEPENDS="nodejs, electron42"
TERMUX_PKG_BUILD_DEPENDS="electron42-headers"
TERMUX_PKG_AUTO_UPDATE=false
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_EXCLUDED_ARCHES="i686"

termux_step_make() {
	termux_error_exit "Work in progress."
	termux_setup_electron "$TERMUX_PKG_SRCDIR/package.json"
	npm i
	npm run build-electron
}

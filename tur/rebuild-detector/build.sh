TERMUX_PKG_HOMEPAGE=https://github.com/maximbaz/rebuild-detector
TERMUX_PKG_DESCRIPTION="Detects which installed libalpm packages need to be rebuilt"
TERMUX_PKG_LICENSE="ISC"
TERMUX_PKG_MAINTAINER="@flosnvjx"
TERMUX_PKG_VERSION=4.4.1
TERMUX_PKG_SRCURL="https://github.com/maximbaz/rebuild-detector/archive/refs/tags/$TERMUX_PKG_VERSION.tar.gz"
TERMUX_PKG_SHA256=1b728629755dd2d45fd63aba1ae7c6e98e5ba0f5e8e36e0f7bbf9cfe2b20156b
TERMUX_PKG_DEPENDS="pacman, binutils, pacman-contrib, pacutils, parallel"
TERMUX_PKG_BUILD_IN_SRC=true
#TERMUX_PKG_AUTO_UPDATE=true

termux_step_configure() {
	true
}

termux_step_make() {
	true
}

termux_step_post_make_install() {
	install -m600 README.md -D "$TERMUX_PREFIX"/share/doc/"$TERMUX_PKG_NAME"/README.md
}

TERMUX_PKG_HOMEPAGE=https://github.com/Edenhofer/fakepkg
TERMUX_PKG_DESCRIPTION="Reassemble installed package from filesystem tree per libalpm database (bacman analogue)"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@flosnvjx"
TERMUX_PKG_VERSION=1.42.2
TERMUX_PKG_SRCURL=https://github.com/Edenhofer/fakepkg/archive/refs/tags/v"$TERMUX_PKG_VERSION".tar.gz
TERMUX_PKG_SHA256=31ca1e3483ffe5b897ebc5997ebdec1342904d6f8f4b51ea77a4aea01ed7b38d
TERMUX_PKG_DEPENDS="file, bsdtar, pacman"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_PLATFORM_INDEPENDENT=true
#TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_TAG_TYPE="newest-tag"

termux_step_configure() {
	true
}

termux_step_make() {
	curl -qgsfL https://www.gnu.org/licenses/old-licenses/gpl-2.0.txt \
		-o LICENSE
}

termux_step_make_install() {
	install -Dm700 -t $TERMUX_PREFIX/bin fakepkg
	install -Dm600 -t $TERMUX_PREFIX/share/man/man1 man/fakepkg.1
}

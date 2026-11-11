TERMUX_PKG_HOMEPAGE="https://www.widelands.org/"
TERMUX_PKG_DESCRIPTION="A free, open source real-time strategy game with singleplayer campaigns and a multiplayer mode"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@IntinteDAO"
TERMUX_PKG_VERSION="1.3.1"
TERMUX_PKG_SRCURL="https://github.com/widelands/widelands/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256="e6f3e8f4fcafd367962dbacde80e26fc63afad38cfe26fadba9c92d4a01bd687"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_DEPENDS="glew, libandroid-execinfo, libandroid-glob, libc++, libicu, libminizip, libpng, opengl, sdl2, sdl2-image, sdl2-mixer, sdl2-ttf, widelands-data, zlib"
TERMUX_PKG_BUILD_DEPENDS="libasio"
TERMUX_PKG_GROUPS="games"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DWL_INSTALL_BINDIR=$TERMUX_PREFIX/bin
-DWL_INSTALL_BASEDIR=$TERMUX_PREFIX/share/doc/$TERMUX_PKG_NAME
-DWL_INSTALL_DATADIR=$TERMUX_PREFIX/share/$TERMUX_PKG_NAME
-DWL_VERSION=$TERMUX_PKG_VERSION
-DOPTION_BUILD_TESTS=OFF
-DOPTION_BUILD_WEBSITE_TOOLS=OFF
-DOPTION_BUILD_CODECHECK=OFF
"

termux_step_pre_configure() {
	LDFLAGS+=" -landroid-glob -landroid-execinfo"
}

TERMUX_PKG_HOMEPAGE="https://www.teeworlds.com/"
TERMUX_PKG_DESCRIPTION="Retro multiplayer 2D shooter"
TERMUX_PKG_LICENSE="ZLIB, custom"
TERMUX_PKG_LICENSE_FILE="license.txt"
TERMUX_PKG_MAINTAINER="@IntinteDAO"
TERMUX_PKG_VERSION="0.7.5"
TERMUX_PKG_SRCURL="https://github.com/teeworlds/teeworlds/releases/download/${TERMUX_PKG_VERSION}/teeworlds-${TERMUX_PKG_VERSION}-src.tar.gz"
TERMUX_PKG_SHA256="fcde2223398e027434ec96315103e9861fc458161b49b15908dc56b8e7a8ecd9"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_DEPENDS="freetype, opengl, sdl2 | sdl2-compat, teeworlds-data, zlib"
TERMUX_PKG_GROUPS="games"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DCLIENT=ON
-DPREFER_BUNDLED_LIBS=OFF
"

termux_step_post_make_install() {
	install -Dm644 "$TERMUX_PKG_BUILDER_DIR/teeworlds.desktop" "$TERMUX_PREFIX/share/applications/teeworlds.desktop"
	install -Dm644 "$TERMUX_PKG_BUILDER_DIR/teeworlds.png" "$TERMUX_PREFIX/share/pixmaps/teeworlds.png"
}

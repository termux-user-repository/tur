TERMUX_PKG_HOMEPAGE=https://supertuxkart.net
TERMUX_PKG_DESCRIPTION="Kart racing game featuring Tux and his friends"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="1.4"
TERMUX_PKG_SRCURL=https://github.com/supertuxkart/stk-code/releases/download/${TERMUX_PKG_VERSION}/SuperTuxKart-${TERMUX_PKG_VERSION}-src.tar.xz
TERMUX_PKG_SHA256=9890392419baf4715313f14d5ad60746f276eed36eb580636caf44e2532c0f03
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_DEPENDS="freetype, harfbuzz, hicolor-icon-theme, libc++, libcurl, libjpeg-turbo, libpng, libsqlite, openal-soft, sdl2, shaderc, supertuxkart-data, libvorbis, zlib"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DBUILD_RECORDER=OFF
-DUSE_WIIUSE=OFF
-DUSE_DNS_C=ON
"

termux_step_post_make_install() {
	touch "$TERMUX_PREFIX"/share/supertuxkart/data/.placeholder
}

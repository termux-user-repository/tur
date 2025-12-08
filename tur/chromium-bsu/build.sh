TERMUX_PKG_HOMEPAGE=https://chromium-bsu.sourceforge.io/
TERMUX_PKG_DESCRIPTION="Fast paced, arcade-style, top-scrolling space shooter"
TERMUX_PKG_LICENSE="Artistic-License-2.0"
TERMUX_PKG_MAINTAINER="@IntinteDAO"
TERMUX_PKG_VERSION=0.9.16.1
TERMUX_PKG_SRCURL=https://downloads.sourceforge.net/project/chromium-bsu/Chromium%20B.S.U.%20source%20code/chromium-bsu-0.9.16.1.tar.gz
TERMUX_PKG_SHA256=a1c141a34d19a59607ae81166a19864eb8c84cf86b155462fed31a6d56e1624a
TERMUX_PKG_DEPENDS="libftgl2, sdl2, sdl2-mixer, sdl2-image, glu, fontconfig, libvorbis, libpng, libglvnd"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--disable-openal
--enable-sdl2
--enable-sdl2mixer
--enable-sdl2image
--disable-glc
"

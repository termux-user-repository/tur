TERMUX_PKG_HOMEPAGE="https://djoffe.com/gnukem"
TERMUX_PKG_DESCRIPTION="Dave Gnukem is an open source retro-style 2D scrolling platform shooter, inspired by and similar to Duke Nukem 1 (a famous original 1991 game that launched the Duke Nukem series)"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@fervi"
TERMUX_PKG_VERSION=1.0.3
TERMUX_PKG_SRCURL=https://github.com/davidjoffe/dave_gnukem/releases/download/${TERMUX_PKG_VERSION}/davegnukem_${TERMUX_PKG_VERSION}.orig.tar.xz
TERMUX_PKG_SHA256=77a64e27ab8c006c8cab5cdec005a020dfe383e9aff35748ff9e426c2708d69c
TERMUX_PKG_DEPENDS="sdl2, sdl2-mixer, sdl2-image"
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_post_get_source() {
	git clone https://github.com/davidjoffe/gnukem_data data --depth=1
	mkdir -p debian/icons/hicolor/128x128/apps/
	wget https://raw.githubusercontent.com/Mailaender/dave_gnukem/1349b0f0caf445370c08c366b8e9acf86d163aaf/debian/icons/hicolor/128x128/apps/davegnukem.png \
		-o debian/icons/hicolor/128x128/apps/davegnukem.png
}

termux_step_post_make_install() {
	ln -sr $TERMUX_PREFIX/games/davegnukem $TERMUX_PREFIX/bin/davegnukem
}

TERMUX_PKG_HOMEPAGE="http://www.scorched3d.co.uk/"
TERMUX_PKG_DESCRIPTION="3D artillery game similar to classic Scorched Earth"
TERMUX_PKG_LICENSE="GPL-2.0-or-later"
TERMUX_PKG_MAINTAINER="@IntinteDAO"
TERMUX_PKG_VERSION="44"
TERMUX_PKG_SRCURL="https://deb.debian.org/debian/pool/main/s/scorched3d/scorched3d_${TERMUX_PKG_VERSION}+dfsg.orig.tar.xz"
TERMUX_PKG_SHA256=5b5e09bd9b2c186545a75cff9dde893edce766fa80b2ae3a6fe80ef7a2b59e38
TERMUX_PKG_DEPENDS="fftw, freetype, glew, glu, libc++, libexpat, libjpeg-turbo, libogg, libpng, libvorbis, lua54, openal-soft, openalut, opengl, scorched3d-data, sdl, sdl-net, wxwidgets, zlib"
TERMUX_PKG_GROUPS="games"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--datadir=$TERMUX_PREFIX/share/games/scorched3d
--with-docdir=$TERMUX_PREFIX/share/doc/scorched3d
ac_cv_path_WX_CONFIG_PATH=$TERMUX_PREFIX/bin/wx-config
"

termux_step_pre_configure() {
	cp -r "$TERMUX_PKG_BUILDER_DIR/avatars" data/
	(cd scripts && perl createAMMakefile.pl)
	autoreconf -fi
	CXXFLAGS+=" -std=c++14"
}

termux_step_post_make_install() {
	local fontdir="$TERMUX_PREFIX/share/games/scorched3d/data/fonts"
	local fontttf="$TERMUX_PREFIX/share/fonts/TTF"
	mkdir -p "$fontdir"
	ln -sf "$fontttf/DejaVuSans.ttf" "$fontdir/dejavusans.ttf"
	ln -sf "$fontttf/DejaVuSansCondensed-Bold.ttf" "$fontdir/dejavusconbd.ttf"
	ln -sf "$fontttf/DejaVuSansMono-Bold.ttf" "$fontdir/dejavusmobd.ttf"

	install -Dm644 -t "$TERMUX_PREFIX/share/applications" "$TERMUX_PKG_BUILDER_DIR/scorched3d.desktop"
	install -Dm644 -t "$TERMUX_PREFIX/share/pixmaps" "$TERMUX_PKG_BUILDER_DIR/scorched3d.png"
}

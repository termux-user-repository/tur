TERMUX_PKG_HOMEPAGE=http://www.nongnu.org/enigma/
TERMUX_PKG_DESCRIPTION="Puzzle game inspired by Oxyd and Rock'n'Bolt"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@IntinteDAO"
TERMUX_PKG_VERSION=1.30
TERMUX_PKG_SRCURL=https://github.com/Enigma-Game/Enigma/releases/download/${TERMUX_PKG_VERSION}/Enigma-${TERMUX_PKG_VERSION}-src.tar.gz
TERMUX_PKG_SHA256=ae64b91fbc2b10970071d0d78ed5b4ede9ee3868de2e6e9569546fc58437f8af
TERMUX_PKG_DEPENDS="gettext, libcurl, libenet, libiconv, libicu, libpng, sdl2, sdl2-gfx, sdl2-image, sdl2-mixer, sdl2-ttf, xerces-c, zlib"
TERMUX_PKG_BUILD_DEPENDS="pkg-config"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="--with-system-enet"
TERMUX_PKG_GROUPS="games"

termux_step_pre_configure() {
	# Enigma's autogen.sh bootstraps subdirectories.
	(cd lib-src/zipios++ && autoreconf -fi)
	(cd lib-src/enet && autoreconf -fi)

	autoreconf -fi
	LDFLAGS+=" -licuuc -licudata -liconv"
}

termux_step_post_configure() {
	# Remove doc and po from SUBDIRS to skip documentation and missing po directory
	sed -i 's/^SUBDIRS = .*/SUBDIRS = lib-src src data etc/' Makefile
}


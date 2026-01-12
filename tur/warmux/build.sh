TERMUX_PKG_HOMEPAGE=http://www.warmux.org
TERMUX_PKG_DESCRIPTION="Worms-like game"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@IntinteDAO"
TERMUX_PKG_VERSION=11.04.1
TERMUX_PKG_SRCURL=https://www.warmux.org/warmux-11.04.1.tar.bz2
TERMUX_PKG_SHA256=789c4f353e4c5ce0a2aba2e82861d3fd0e5218bc76d8da1a332f2c7b1b27e4ee
TERMUX_PKG_DEPENDS="libcurl, libpng, libxml2, sdl, sdl-gfx, sdl-image, sdl-mixer, sdl-net, sdl-ttf"
TERMUX_PKG_GROUPS="games"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--with-sdl-prefix=$TERMUX_PREFIX
--with-libcurl=$TERMUX_PREFIX
--with-libxml2-prefix=$TERMUX_PREFIX
--disable-static
--with-datadir-name=$TERMUX_PREFIX/share/games/warmux
--with-font-path=$TERMUX_PREFIX/share/games/warmux/font/VL-Gothic-Regular.ttf
"

termux_step_pre_configure() {
	aclocal -I m4
	autoreconf -vfi

	# Fix library checks by ensuring LDFLAGS is used and LIBS is clean
	export LIBS="-lSDL -lSDL_image -lSDL_mixer -lSDL_net -lSDL_ttf -lSDL_gfx -lcurl -lxml2 -lfribidi -lpng16 -lz -lm"
	export LDFLAGS="$LDFLAGS $LIBS"

	# Fix C++11 narrowing errors and missing includes
	export CXXFLAGS="$CXXFLAGS -Wno-c++11-narrowing -Wno-narrowing -I$TERMUX_PREFIX/include/SDL -I$TERMUX_PREFIX/include/fribidi"
	export CPPFLAGS="$CPPFLAGS -I$TERMUX_PREFIX/include/SDL -I$TERMUX_PREFIX/include/fribidi"
	export CFLAGS="$CFLAGS -I$TERMUX_PREFIX/include/SDL -I$TERMUX_PREFIX/include/fribidi"
}

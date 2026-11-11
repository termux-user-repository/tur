TERMUX_PKG_HOMEPAGE=https://www.freeciv.org/
TERMUX_PKG_DESCRIPTION="Turn-based multiplayer strategy game inspired by the Civilization series"
TERMUX_PKG_LICENSE="GPL-2.0-or-later"
TERMUX_PKG_MAINTAINER="@IntinteDAO"
TERMUX_PKG_VERSION="3.2.7"
TERMUX_PKG_SRCURL="https://files.freeciv.org/stable/freeciv-${TERMUX_PKG_VERSION}.tar.xz"
TERMUX_PKG_SHA256=2720076d50f29db42cdc5e510e7c098f7793f7c0ac410fdf390a52bc57507917
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_DEPENDS="freeciv-data, gettext, gtk3, libbz2, libcurl, libiconv, libicu, liblzma, lua54, readline, sdl2 | sdl2-compat, sdl2-gfx, sdl2-image, sdl2-mixer, sdl2-ttf, sqlite, zlib, zstd"
TERMUX_PKG_BUILD_DEPENDS="pkg-config"
TERMUX_PKG_HOSTBUILD=true
TERMUX_PKG_GROUPS="games"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--enable-client=gtk3.22,sdl2
--enable-fcmp=gtk3,cli
--disable-ruledit
--with-sqlite3-prefix=$TERMUX_PREFIX
"

termux_step_host_build() {
	mkdir -p "$TERMUX_PKG_HOSTBUILD_DIR/bin"
	local LUA_SRCS=$(find "$TERMUX_PKG_SRCDIR/dependencies/lua-5.4/src" -name "*.c" ! -name "lua.c" ! -name "luac.c")
	gcc -O2 \
		-I"$TERMUX_PKG_SRCDIR/dependencies/lua-5.4/src" \
		-I"$TERMUX_PKG_SRCDIR/dependencies/tolua-5.2/include" \
		"$TERMUX_PKG_SRCDIR/dependencies/tolua-5.2/src/bin/tolua.c" \
		"$TERMUX_PKG_SRCDIR/dependencies/tolua-5.2/src/bin/toluabind.c" \
		"$TERMUX_PKG_SRCDIR/dependencies/tolua-5.2/src/lib/"*.c \
		$LUA_SRCS \
		-lm \
		-o "$TERMUX_PKG_HOSTBUILD_DIR/bin/tolua"
}

termux_step_pre_configure() {
	export PATH="$TERMUX_PKG_HOSTBUILD_DIR/bin:$PATH"
	LDFLAGS+=" -liconv"
}

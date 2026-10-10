TERMUX_PKG_HOMEPAGE=https://megaglest.org/
TERMUX_PKG_DESCRIPTION="A free and open source 3D real-time strategy game"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@IntinteDAO"
TERMUX_PKG_VERSION=3.13.0
TERMUX_PKG_SRCURL=(
	https://github.com/MegaGlest/megaglest-source/archive/refs/tags/${TERMUX_PKG_VERSION}.tar.gz
	https://github.com/MegaGlest/megaglest-data/releases/download/${TERMUX_PKG_VERSION}/megaglest-standalone-data-${TERMUX_PKG_VERSION}.tar.xz
)
TERMUX_PKG_SHA256=(
	e02e58c2329558cc5d67374b5e5f9b3cfaafc300b96feff71df8d4b0d39e1eaa
	996040acfb338cfcbd0612b13db9c1734a7588bcc60c7e9b87e9fd619629dda3
)
TERMUX_PKG_DEPENDS="curl, freetype, fribidi, glew, glib, libandroid-glob, libftgl2, libjpeg-turbo, libpng, libvorbis, libxml2, lua52, megaglest-data, openal-soft, sdl2"
TERMUX_PKG_GROUPS="games"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DCMAKE_POLICY_VERSION_MINIMUM=3.5
-DBUILD_MEGAGLEST_MAP_EDITOR=OFF
-DBUILD_MEGAGLEST_MODEL_VIEWER=OFF
-DCMAKE_SYSTEM_NAME=OpenBSD
-DMEGAGLEST_DATA_INSTALL_PATH=share/games/megaglest/
-DHELP2MAN=OFF
-DFORCE_STREFLOP_SOFTWRAPPER=ON
"

termux_step_pre_configure() {
	LDFLAGS+=" -landroid-glob -Wl,--no-as-needed,-lOpenSLES,--as-needed"
	CFLAGS+=" -D__OpenBSD__"
	CXXFLAGS+=" -D__OpenBSD__"
	TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" -DLUA_MATH_LIBRARY=${TERMUX_STANDALONE_TOOLCHAIN}/sysroot/usr/lib/${TERMUX_HOST_PLATFORM}/${TERMUX_PKG_API_LEVEL}/libm.so"
}

termux_step_post_make_install() {
	local _datadir="$TERMUX_PREFIX/share/games/megaglest"

	# Install game data — the engine expects data/ maps/ etc. directly under the data path
	cp -r "$TERMUX_PKG_SRCDIR"/{data,maps,scenarios,techs,tilesets,tutorials} "$_datadir/"

	# Install data documentation
	mkdir -p "$TERMUX_PREFIX/share/doc/megaglest-data"
	cp -r "$TERMUX_PKG_SRCDIR/docs/"* "$TERMUX_PREFIX/share/doc/megaglest-data/"

	# Install desktop entry and icon
	install -Dm644 "$TERMUX_PKG_BUILDER_DIR/megaglest.desktop" "$TERMUX_PREFIX/share/applications/megaglest.desktop"
	install -Dm644 "$TERMUX_PKG_SRCDIR/data/core/menu/textures/logo1.png" "$TERMUX_PREFIX/share/pixmaps/megaglest.png"
	install -Dm644 "$TERMUX_PKG_SRCDIR/data/core/menu/textures/logo1.png" "$TERMUX_PREFIX/share/icons/hicolor/128x128/apps/megaglest.png"
}

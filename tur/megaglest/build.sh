TERMUX_PKG_HOMEPAGE=https://megaglest.org/
TERMUX_PKG_DESCRIPTION="A free and open source 3D real-time strategy game"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@IntinteDAO"
TERMUX_PKG_VERSION=3.13.0
TERMUX_PKG_SRCURL=https://github.com/MegaGlest/megaglest-source/archive/refs/tags/${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=e02e58c2329558cc5d67374b5e5f9b3cfaafc300b96feff71df8d4b0d39e1eaa
TERMUX_PKG_DEPENDS="glib, openal-soft, sdl2, libvorbis, libjpeg-turbo, libpng, freetype, curl, libxml2, wxwidgets, lua52, fribidi, libandroid-glob, libftgl2"

TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DCMAKE_POLICY_VERSION_MINIMUM=3.5
-DLUA_LIBRARIES=${TERMUX_PREFIX}/lib/liblua5.2.so
-DLUA_INCLUDE_DIR=${TERMUX_PREFIX}/include/lua5.2
-DLUA_MATH_LIBRARY=/system/lib64/libm.so
-DWANT_STATIC_LIBS=OFF
-DBUILD_SHARED_LIBS=ON
-DBUILD_MEGAGLEST_MAP_EDITOR=OFF
-DCMAKE_SYSTEM_NAME=OpenBSD
-DBUILD_MEGAGLEST_MODEL_VIEWER=OFF
-DMEGAGLEST_DATA_INSTALL_PATH=share/games/megaglest/
-DWANT_DEV_OUTPATH=ON
"

termux_step_pre_configure() {
	export LDFLAGS+=" -landroid-glob -Wl,--no-as-needed,-lOpenSLES,--as-needed"
	export CFLAGS+=" -D__OpenBSD__"
	export CXXFLAGS+=" -D__OpenBSD__"
}

termux_step_post_make_install() {
	echo "POST INSTALL for Menu entries"
}
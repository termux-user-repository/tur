TERMUX_PKG_HOMEPAGE=https://www.supertux.org
TERMUX_PKG_DESCRIPTION="SuperTux is a jump'n'run game with strong inspiration from the Super Mario Bros. games for the various Nintendo platforms."
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@IntinteDAO"
TERMUX_PKG_VERSION="0.7.0-beta.1"
TERMUX_PKG_SRCURL=https://github.com/SuperTux/supertux/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=df3e702afdd6c14b936e68dbbf8fc7e916be2d527b159144b07fc328f7653db8
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_BUILD_DEPENDS="boost-headers"
TERMUX_PKG_DEPENDS="boost, glm, sdl2, sdl2-image, sdl2-ttf, glew, openal-soft, libphysfs, freetype, libandroid-execinfo, fmt, supertux-data, libandroid-spawn"
TERMUX_PKG_FORCE_CMAKE=true
TERMUX_ON_DEVICE_BUILD=false
TERMUX_PKG_GROUPS="games"

TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DANDROID=OFF
-DBoost_INCLUDE_DIR=$TERMUX_PREFIX/include
-DCMAKE_INSTALL_PREFIX=$TERMUX_PREFIX
-DIS_SUPERTUX_RELEASE=true
-DINSTALL_SUBDIR_BIN=bin
-DINSTALL_SUBDIR_SHARE=share/games/supertux
-DINSTALL_SUBDIR_DOC=share/doc/supertux
"

termux_step_pre_configure() {
	export LDFLAGS+=" -Wl,--no-as-needed,-lOpenSLES,--as-needed -landroid-spawn -llog"
	export CMAKE_PREFIX_PATH=$TERMUX_PREFIX

	git clone --recurse-submodules https://github.com/SuperTux/tinygettext external/tinygettext
	git clone --recurse-submodules https://github.com/SuperTux/simplesquirrel external/simplesquirrel
	git clone --recurse-submodules https://github.com/SuperTux/sexp-cpp external/sexp-cpp
	git clone --recurse-submodules https://github.com/SuperTux/SDL_ttf external/SDL_ttf

}

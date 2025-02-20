TERMUX_PKG_HOMEPAGE=https://www.supertux.org
TERMUX_PKG_DESCRIPTION="SuperTux is a jump'n'run game with strong inspiration from the Super Mario Bros. games for the various Nintendo platforms."
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="0.6.3"
TERMUX_PKG_SRCURL="https://github.com/SuperTux/supertux/releases/download/v${TERMUX_PKG_VERSION}/SuperTux-v${TERMUX_PKG_VERSION}-Source.tar.gz"
TERMUX_PKG_SHA256=f7940e6009c40226eb34ebab8ffb0e3a894892d891a07b35d0e5762dd41c79f6
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_BUILD_DEPENDS="boost-headers"
TERMUX_PKG_DEPENDS="boost, glm, sdl2, sdl2-image, sdl2-ttf, glew, openal-soft, libphysfs, supertux2-data"

TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DBoost_INCLUDE_DIR=$TERMUX_PREFIX/include
-DCMAKE_INSTALL_PREFIX=$TERMUX_PREFIX
-DIS_SUPERTUX_RELEASE=true
"

termux_step_pre_configure() {
	termux_setup_cmake
}

termux_step_configure() {
	export CMAKE_PREFIX_PATH=/data/data/com.termux/files/usr
	cmake . $TERMUX_PKG_EXTRA_CONFIGURE_ARGS
}

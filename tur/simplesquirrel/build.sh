TERMUX_PKG_HOMEPAGE=https://github.com/SuperTux/simplesquirrel
TERMUX_PKG_DESCRIPTION="A simple C++ wrapper for the Squirrel programming language"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION=2024.12.31
TERMUX_PKG_SRCURL=git+https://github.com/SuperTux/simplesquirrel.git
TERMUX_PKG_GIT_BRANCH=master
TERMUX_PKG_DEPENDS="squirrel3"
TERMUX_PKG_AUTO_UPDATE=false

TERMUX_PKG_EXTRA_CONFIGURE_ARGS="-DSSQ_USE_SQ_SUBMODULE=OFF"

termux_step_pre_configure() {
	export TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" -DCMAKE_ANDROID_STANDALONE_TOOLCHAIN=$TERMUX_STANDALONE_TOOLCHAIN"
	termux_setup_ninja
	# Ensure it uses system squirrel
	sed -i 's/add_subdirectory("libs\/squirrel")/#add_subdirectory("libs\/squirrel")/' CMakeLists.txt
	# Fix SQUIRREL_INCLUDE_DIR when not using submodule
	sed -i 's/set(SQUIRREL_INCLUDE_DIR ${PROJECT_SOURCE_DIR}\/libs\/squirrel\/include)/set(SQUIRREL_INCLUDE_DIR ${TERMUX_PREFIX}\/include)/' CMakeLists.txt
}

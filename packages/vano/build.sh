TERMUX_PKG_HOMEPAGE=https://github.com/therealviren/vano
TERMUX_PKG_DESCRIPTION="A modern, customizable terminal text editor written in C++"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="Viren Sahti <https://github.com/therealviren>"
TERMUX_PKG_VERSION=1.4.3
TERMUX_PKG_SRCURL=https://github.com/therealviren/vano/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=3d520a11ec59f431193b7dfc2717df2e4ea942ae8684bf8f6c901905de564961
TERMUX_PKG_DEPENDS="libc++"
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_make_install() {
    mkdir -p build
    cd build
    cmake .. -DCMAKE_INSTALL_PREFIX=$TERMUX_PREFIX
    cmake --build . -j$TERMUX_MAKE_PROCESSES
    cmake --install .
}

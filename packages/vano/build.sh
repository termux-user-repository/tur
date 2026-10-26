TERMUX_PKG_HOMEPAGE=https://github.com/therealviren/vano
TERMUX_PKG_DESCRIPTION="A modern, customizable terminal text editor written in C++"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="Viren Sahti <https://github.com/therealviren>"
TERMUX_PKG_VERSION=1.4.13
TERMUX_PKG_SRCURL=https://github.com/therealviren/vano/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=282cd2004a955f0e69d02918f857af049f2543241539a673e17c92ca29b9dec8

TERMUX_PKG_DEPENDS="libc++"
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_make_install() {
    cmake -B build -S . -DCMAKE_INSTALL_PREFIX=$TERMUX_PREFIX
    cmake --build build -j ${TERMUX_MAKE_PROCESSES:-$(nproc)}
    cmake --install build
}

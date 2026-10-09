TERMUX_PKG_HOMEPAGE="https://archive.ubuntu.com/ubuntu/pool/main/i/intel-processor-trace/"
TERMUX_PKG_DESCRIPTION="Auto generated package for intel-processor-trace"
TERMUX_PKG_LICENSE="Expat"
TERMUX_PKG_MAINTAINER="Victor Seva <vseva@debian.org>"
TERMUX_PKG_VERSION="2.0.5"
TERMUX_PKG_SRCURL="https://archive.ubuntu.com/ubuntu/pool/main/i/intel-processor-trace/"

termux_step_configure() {
  termux_setup_cmake
  cmake -B build \
    -DCMAKE_INSTALL_PREFIX="${TERMUX_PREFIX}" \
    -DCMAKE_BUILD_TYPE=Release
}

termux_step_make() {
  cmake --build build -j ${TERMUX_PKG_MAKE_PROCESSES}
}

termux_step_make_install() {
  cmake --install build
}

TERMUX_PKG_HOMEPAGE="https://archive.ubuntu.com/ubuntu/pool/main/g/gcc-16/"
TERMUX_PKG_DESCRIPTION="Auto generated package for gcc-16"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="Ubuntu Core developers <ubuntu-devel-discuss@lists.ubuntu.com>"
TERMUX_PKG_VERSION="16"
TERMUX_PKG_SRCURL="https://archive.ubuntu.com/ubuntu/pool/main/g/gcc-16/"

TERMUX_PKG_DEPENDS="rust"

termux_step_make() {
  cargo build --jobs ${TERMUX_PKG_MAKE_PROCESSES} --target ${CARGO_TARGET_NAME} --release
}

termux_step_make_install() {
  install -Dm755 -t "${TERMUX_PREFIX}/bin" "target/${CARGO_TARGET_NAME}/release/${TERMUX_PKG_NAME}"
}

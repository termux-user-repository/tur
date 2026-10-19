TERMUX_PKG_HOMEPAGE="https://archive.ubuntu.com/ubuntu/pool/main/l/linux-realtime/"
TERMUX_PKG_DESCRIPTION="Auto generated package for linux-realtime"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="Ubuntu Kernel Team <kernel-team@lists.ubuntu.com>"
TERMUX_PKG_VERSION="7.0.0"
TERMUX_PKG_SRCURL="https://archive.ubuntu.com/ubuntu/pool/main/l/linux-realtime/"

TERMUX_PKG_DEPENDS="rust"

termux_step_make() {
  cargo build --jobs ${TERMUX_PKG_MAKE_PROCESSES} --target ${CARGO_TARGET_NAME} --release
}

termux_step_make_install() {
  install -Dm755 -t "${TERMUX_PREFIX}/bin" "target/${CARGO_TARGET_NAME}/release/${TERMUX_PKG_NAME}"
}

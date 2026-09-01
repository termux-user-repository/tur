TERMUX_PKG_HOMEPAGE=https://github.com/termux-user-repository/tur
TERMUX_PKG_DESCRIPTION="Run Docker inside a QEMU/Alpine VM on Termux, no root required"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@gourangadassamrat"
TERMUX_PKG_VERSION=1.0.0
TERMUX_PKG_AUTO_UPDATE=false
TERMUX_PKG_SKIP_SRC_EXTRACT=true
TERMUX_PKG_PLATFORM_INDEPENDENT=true
TERMUX_PKG_DEPENDS="qemu-utils, qemu-system-x86-64-headless, openssh, wget"

termux_step_make_install() {
  install -Dm700 "$TERMUX_PKG_BUILDER_DIR/docker-qemu.sh" \
    "$TERMUX_PREFIX/bin/docker-qemu"
  install -Dm600 "$TERMUX_PKG_BUILDER_DIR/alpine-provision.sh" \
    "$TERMUX_PREFIX/share/docker-qemu/alpine-provision.sh"
}

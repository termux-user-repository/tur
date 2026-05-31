TERMUX_PKG_HOMEPAGE=https://hoshino946493.github.io/
TERMUX_PKG_DESCRIPTION="A lightweight PRoot container management script for Termux"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="Hoshino946493"
TERMUX_PKG_VERSION=1.0.0
TERMUX_PKG_SRCURL=https://github.com/Hoshino946493/VRoot/archive/refs/heads/main.tar.gz
TERMUX_PKG_SHA256=193a2c8bc25c1791cba6f691625022326352ec7a212730011b897baabb0903d5
TERMUX_PKG_DEPENDS="bash, proot, coreutils"
TERMUX_PKG_PLATFORM_INDEPENDENT=true
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_make_install() {
    install -Dm755 vroot $PREFIX/bin/vroot
}


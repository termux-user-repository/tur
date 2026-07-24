TERMUX_PKG_HOMEPAGE=https://github.com/javedahmed82/antigravity-termux
TERMUX_PKG_DESCRIPTION="Antigravity CLI bridge for Termux (Glibc Bridge via Ubuntu proot)"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="javedahmed82 <javedjakali82@gmail.com>"
TERMUX_PKG_VERSION=1.0.6
TERMUX_PKG_SRCURL=https://github.com/javedahmed82/antigravity-termux/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=5f5789d1dee76fa7627f64ffa9c1fe7d1ba392a303964647ec38dc18805738d6
TERMUX_PKG_DEPENDS="proot-distro, curl, tar, coreutils"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_PLATFORM_INDEPENDENT=true

termux_step_make_install() {
    mkdir -p $TERMUX_PREFIX/bin
    cp $TERMUX_PKG_SRCDIR/install-agy.sh $TERMUX_PREFIX/bin/antigravity-termux-setup
    chmod +x $TERMUX_PREFIX/bin/antigravity-termux-setup
}

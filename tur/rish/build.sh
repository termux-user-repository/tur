TERMUX_PKG_HOMEPAGE=https://github.com/RikkaApps/Shizuku
TERMUX_PKG_DESCRIPTION="Rish client for Shizuku implementation"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="Nixxy-lv <nixdev888@gmail.com>"
TERMUX_PKG_VERSION=2026.07.12
TERMUX_PKG_SKIP_SRC_EXTRACT=true
TERMUX_PKG_PLATFORM_INDEPENDENT=true

termux_step_make_install() {
    mkdir -p $TERMUX_PREFIX/bin
    mkdir -p $TERMUX_PREFIX/share/rish
    
    cp $TERMUX_PKG_BUILDER_DIR/rish $TERMUX_PREFIX/bin/
    cp $TERMUX_PKG_BUILDER_DIR/rish_shizuku.dex $TERMUX_PREFIX/share/rish/
    
    chmod 755 $TERMUX_PREFIX/bin/rish
    chmod 400 $TERMUX_PREFIX/share/rish/rish_shizuku.dex
}


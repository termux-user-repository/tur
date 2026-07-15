TERMUX_PKG_HOMEPAGE=https://gitlab.com/protesilaos/lemonbar-xft
TERMUX_PKG_DESCRIPTION="Lightweight status bar with Xft support (Protesilaos fork)"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_LICENSE_FILE="LICENSE"
TERMUX_PKG_MAINTAINER="Muhammad <nurmuhammedjoy@gmail.com>"
TERMUX_PKG_VERSION=1.3
TERMUX_PKG_SRCURL=https://gitlab.com/protesilaos/lemonbar-xft/-/archive/xft-port/lemonbar-xft-xft-port.tar.gz
TERMUX_PKG_SHA256=8ffc88d2873e8dc87c909fbd005f6f893abab37df0d7780d8eb308fa8506aee0
TERMUX_PKG_BUILD_DEPENDS="xorgproto, freetype, libxcb, libx11, libxft"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_EXTRA_MAKE_ARGS="PREFIX=$TERMUX_PREFIX"

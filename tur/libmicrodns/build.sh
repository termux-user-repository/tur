TERMUX_PKG_HOMEPAGE="https://github.com/videolabs/libmicrodns"
TERMUX_PKG_DESCRIPTION="Minimal mDNS resolver library"
TERMUX_PKG_LICENSE="LGPL-2.1"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="0.2.0"
TERMUX_PKG_SRCURL="https://github.com/videolabs/libmicrodns/archive/refs/tags/${TERMUX_PKG_VERSION}/libmicrodns-${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256="9864a088ffef4d4255d5abf63c6f603d1dc343dfec2809ff0c3f1624045b80fa"
TERMUX_PKG_AUTO_UPDATE=true

TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-Dtests=disabled
-Dexamples=disabled
"

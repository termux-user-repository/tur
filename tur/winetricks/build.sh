TERMUX_PKG_HOMEPAGE=https://github.com/Winetricks/winetricks
TERMUX_PKG_DESCRIPTION="Work around problems and install applications under Wine"
TERMUX_PKG_LICENSE="LGPL-2.1"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="20260125"
TERMUX_PKG_SRCURL=https://github.com/Winetricks/winetricks/archive/refs/tags/${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=2890bd9fbbade4638e58b4999a237273192df03b58516ae7b8771e09c22d2f56
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_MAKE_INSTALL_TARGET="install DESTDIR=${TERMUX_PREFIX%%/usr}"

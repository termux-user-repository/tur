TERMUX_PKG_HOMEPAGE=https://github.com/Winetricks/winetricks
TERMUX_PKG_DESCRIPTION="Work around problems and install applications under Wine"
TERMUX_PKG_LICENSE="LGPL-2.1"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="20250102"
TERMUX_PKG_SRCURL=https://github.com/Winetricks/winetricks/archive/refs/tags/${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=24d339806e3309274ee70743d76ff7b965fef5a534c001916d387c924eebe42e
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_MAKE_INSTALL_TARGET="install DESTDIR=${TERMUX_PREFIX%%/usr}"

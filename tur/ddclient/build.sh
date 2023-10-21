TERMUX_PKG_HOMEPAGE=https://github.com/ddclient/ddclient
TERMUX_PKG_DESCRIPTION="Update dynamic DNS entries for accounts on many dynamic DNS services"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="3.11.0"
TERMUX_PKG_SRCURL=https://github.com/ddclient/ddclient/archive/refs/tags/v$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=0e7ad53049c7e8699a316c834cf12cf14134671c7d87a44fe5783a481b886b64
TERMUX_PKG_DEPENDS="perl"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_PLATFORM_INDEPENDENT=true
TERMUX_PKG_AUTO_UPDATE=true

TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--prefix=$TERMUX_PREFIX
--sysconfdir=$TERMUX_PREFIX/etc/ddclient
--localstatedir=$TERMUX_PREFIX/var
"

termux_step_pre_configure() {
	autoreconf -fi
}

TERMUX_PKG_HOMEPAGE=https://github.com/ddclient/ddclient
TERMUX_PKG_DESCRIPTION="Update dynamic DNS entries for accounts on many dynamic DNS services"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="4.0.0"
TERMUX_PKG_SRCURL=https://github.com/ddclient/ddclient/archive/refs/tags/v$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=4b37c99ac0011102d7db62f1ece7ff899b06df3d4b172e312703931a3c593c93
TERMUX_PKG_DEPENDS="curl, perl"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_PLATFORM_INDEPENDENT=true
TERMUX_PKG_AUTO_UPDATE=true

TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--prefix=$TERMUX_PREFIX
--sysconfdir=$TERMUX_PREFIX/etc/ddclient
--localstatedir=$TERMUX_PREFIX/var
--with-curl=$TERMUX_PREFIX/bin/curl
"

termux_step_pre_configure() {
	autoreconf -fi
}

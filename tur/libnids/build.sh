TERMUX_PKG_HOMEPAGE=http://libnids.sourceforge.net/
TERMUX_PKG_DESCRIPTION="An implementation of an E-component of Network Intrusion Detection System"
TERMUX_PKG_LICENSE="LGPL-2.1"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="1.26"
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=https://github.com/MITRECND/libnids/archive/$TERMUX_PKG_VERSION/libnids-$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=3f3e9f99a83cd37bc74af83d415c5e3a7505f5b190dfaf456b0849e0054f6733
TERMUX_PKG_DEPENDS="glib, libnet, libnsl, libpcap, libtirpc"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--man=$TERMUX_PREFIX/share/man
"

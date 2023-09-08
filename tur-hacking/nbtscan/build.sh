TERMUX_PKG_HOMEPAGE=https://github.com/resurrecting-open-source-projects/nbtscan
TERMUX_PKG_DESCRIPTION="Scan networks searching for NetBIOS information"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=1.7.2
TERMUX_PKG_SRCURL=https://github.com/resurrecting-open-source-projects/nbtscan/archive/refs/tags/$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=00e61be7c05cd3a34d5fefedffff86dc6add02d4c728b22e13fb9fbeabba1984

termux_step_pre_configure() {
	./autogen.sh
}

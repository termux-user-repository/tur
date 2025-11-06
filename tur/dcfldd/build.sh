TERMUX_PKG_HOMEPAGE=https://github.com/resurrecting-open-source-projects/dcfldd
TERMUX_PKG_DESCRIPTION="dd(1) added features for forensics and security"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@flosnvjx"
TERMUX_PKG_VERSION="1.9.3"
TERMUX_PKG_SRCURL="https://github.com/resurrecting-open-source-projects/dcfldd/archive/refs/tags/v$TERMUX_PKG_VERSION.tar.gz"
TERMUX_PKG_SHA256=e5813e97bbc8f498f034f5e05178489c1be86de015e8da838de59f90f68491e7
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	autoreconf -fi
}

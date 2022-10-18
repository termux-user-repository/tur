TERMUX_PKG_HOMEPAGE=https://github.com/resurrecting-open-source-projects/dcfldd
TERMUX_PKG_DESCRIPTION="dd(1) added features for forensics and security"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@flosnvjx"
TERMUX_PKG_VERSION="1.8"
TERMUX_PKG_SRCURL="https://github.com/resurrecting-open-source-projects/dcfldd/archive/refs/tags/v$TERMUX_PKG_VERSION.tar.gz"
TERMUX_PKG_SHA256=107cd14b37f6d34c97bcc4d6c390adf4a3a87e04053f9159befae4714e3afd55
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	autoreconf -fi
}

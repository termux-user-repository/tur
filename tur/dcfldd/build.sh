TERMUX_PKG_HOMEPAGE=https://github.com/resurrecting-open-source-projects/dcfldd
TERMUX_PKG_DESCRIPTION="dd(1) added features for forensics and security"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@flosnvjx"
TERMUX_PKG_VERSION="1.9"
TERMUX_PKG_SRCURL="https://github.com/resurrecting-open-source-projects/dcfldd/archive/refs/tags/v$TERMUX_PKG_VERSION.tar.gz"
TERMUX_PKG_SHA256=87ebc6e40b1fcec96895eaf0effba4a024ee1431c8fb65af567b46ea604d2e8e
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	autoreconf -fi
}

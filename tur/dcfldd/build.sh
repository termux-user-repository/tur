TERMUX_PKG_HOMEPAGE=https://github.com/resurrecting-open-source-projects/dcfldd
TERMUX_PKG_DESCRIPTION="dd(1) added features for forensics and security"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@flosnvjx"
TERMUX_PKG_VERSION="1.9.1"
TERMUX_PKG_SRCURL="https://github.com/resurrecting-open-source-projects/dcfldd/archive/refs/tags/v$TERMUX_PKG_VERSION.tar.gz"
TERMUX_PKG_SHA256=efb9406b7186cbe6c3edf8ff438ff37c915b21dad026bd27ee4f4cc5a6644bd8
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	autoreconf -fi
}

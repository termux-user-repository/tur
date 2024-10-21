TERMUX_PKG_HOMEPAGE=https://github.com/resurrecting-open-source-projects/dcfldd
TERMUX_PKG_DESCRIPTION="dd(1) added features for forensics and security"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@flosnvjx"
TERMUX_PKG_VERSION="1.9.2"
TERMUX_PKG_SRCURL="https://github.com/resurrecting-open-source-projects/dcfldd/archive/refs/tags/v$TERMUX_PKG_VERSION.tar.gz"
TERMUX_PKG_SHA256=52468122e915273eaffde94cb0b962adaefe260b8af74e98e1282e2177f01194
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	autoreconf -fi
}

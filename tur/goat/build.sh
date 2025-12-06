TERMUX_PKG_HOMEPAGE=https://github.com/bluesky-social/goat
TERMUX_PKG_DESCRIPTION="Go AT protocol CLI tool"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@ancientcatz"
TERMUX_PKG_VERSION="0.2.1"
TERMUX_PKG_SRCURL=https://github.com/bluesky-social/goat/archive/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=77e7f2eda9a11e92808dbb190ffaec1b7e3ee005bdc6c57a7a858b6b435e6aa2
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	termux_setup_golang
}

termux_step_make() {
	export GOEXPERIMENT='greenteagc'
	go build -ldflags "-s -w"
}

termux_step_make_install() {
	install -Dm700 goat "$TERMUX_PREFIX/bin/goat"
}

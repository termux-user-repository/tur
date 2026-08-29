TERMUX_PKG_HOMEPAGE=https://github.com/bluesky-social/goat
TERMUX_PKG_DESCRIPTION="Go AT protocol CLI tool"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@ancientcatz"
TERMUX_PKG_VERSION="0.2.4"
TERMUX_PKG_SRCURL=https://github.com/bluesky-social/goat/archive/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=0fa0e599bcc556f2dfde92beb2f63f4462ff74b2c695f1f5f8f35584607fde1c
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	termux_setup_golang
}

termux_step_make() {
	export GOEXPERIMENT='greenteagc'
	go build -ldflags "-s -w -X 'main.Version=${TERMUX_PKG_VERSION}'"
}

termux_step_make_install() {
	install -Dm700 goat "$TERMUX_PREFIX/bin/goat"
}

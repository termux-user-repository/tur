TERMUX_PKG_HOMEPAGE=https://github.com/bluesky-social/goat
TERMUX_PKG_DESCRIPTION="Go AT protocol CLI tool"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@ancientcatz"
TERMUX_PKG_VERSION="0.2.7"
TERMUX_PKG_SRCURL=https://github.com/bluesky-social/goat/archive/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=3ab36603983d516cc0cb91c384e97554fa22a124bedfc91cb06c4fb7a5c774d5
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

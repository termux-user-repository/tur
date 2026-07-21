TERMUX_PKG_HOMEPAGE=https://github.com/HashShin/coded
TERMUX_PKG_DESCRIPTION="A mobile-first code editor that runs in your browser"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@HashShin"
TERMUX_PKG_VERSION="0.1.2"
TERMUX_PKG_SRCURL="https://github.com/HashShin/coded/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=ee7595713c0035356dfc23ae6705689fc8864d47574f29300bdb4a619327057b
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	termux_setup_golang
}

termux_step_make() {
	go build \
		-trimpath \
		-ldflags="-s -w" \
		-o coded \
		.
}

termux_step_make_install() {
	install -Dm755 coded \
		"${TERMUX_PREFIX}/bin/coded"
}

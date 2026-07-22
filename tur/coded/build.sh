TERMUX_PKG_HOMEPAGE=https://github.com/HashShin/coded
TERMUX_PKG_DESCRIPTION="A mobile-first code editor that runs in your browser"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@HashShin"
TERMUX_PKG_VERSION="0.1.9"
TERMUX_PKG_SRCURL="https://github.com/HashShin/coded/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=3b1f944dfee5394079e822455684150885b3bbeff879214fa51387588a3cf950
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	termux_setup_golang
}

termux_step_make() {
	go build \
		-trimpath \
		-ldflags="-s -w -X main.version=${TERMUX_PKG_VERSION}" \
		-o coded \
		.
}

termux_step_make_install() {
	install -Dm755 coded \
		"${TERMUX_PREFIX}/bin/coded"
}

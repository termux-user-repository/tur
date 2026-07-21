TERMUX_PKG_HOMEPAGE=https://github.com/HashShin/coded
TERMUX_PKG_DESCRIPTION="A mobile-first code editor that runs in your browser"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@HashShin"
TERMUX_PKG_VERSION="0.1.7"
TERMUX_PKG_SRCURL="https://github.com/HashShin/coded/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=e6b566dccbfe59d9cb02ebf1654a87a7a81acbc21e7ebff1b1e8f8dd07f9bcf7
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

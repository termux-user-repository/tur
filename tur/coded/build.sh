TERMUX_PKG_HOMEPAGE=https://github.com/HashShin/coded
TERMUX_PKG_DESCRIPTION="A mobile-first code editor that runs in your browser"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@HashShin"
TERMUX_PKG_VERSION="0.2.2"
TERMUX_PKG_SRCURL="https://github.com/HashShin/coded/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=8a7b973ad693c62c3b25a2fade1d5f0bbb2fa7735b298ceb23e633973b2dd8ed
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

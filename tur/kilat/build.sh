TERMUX_PKG_HOMEPAGE=https://github.com/ihsannyy/kilat
TERMUX_PKG_DESCRIPTION="Ultra-lightweight JavaScript and TypeScript runtime for Termux"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@ihsannyy"
TERMUX_PKG_VERSION="5.0.0"
TERMUX_PKG_SRCURL="https://github.com/ihsannyy/kilat/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=00f68d67c9abae14c55842d6fb4a14a6af500c0271a2bdb3550adf213d751df4
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	termux_setup_golang
}

termux_step_make() {
	go build \
		-trimpath \
		-ldflags="-s -w" \
		-o kilat \
		./cmd/kilat
}

termux_step_make_install() {
	install -Dm755 kilat \
		"${TERMUX_PREFIX}/bin/kilat"
}

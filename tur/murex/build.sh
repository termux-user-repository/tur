TERMUX_PKG_HOMEPAGE=https://github.com/lmorg/murex
TERMUX_PKG_DESCRIPTION="Murex: A Smarter Shell"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@everywhereless"
TERMUX_PKG_VERSION="7.4.2002"
TERMUX_PKG_SRCURL="https://github.com/lmorg/murex/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=b3b1b79d89e2ab74bd15f3632a1878a4c958e2a0db272852834095e57f8644e4
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	termux_setup_golang
}

termux_step_make() {
	go build -o murex .
}

termux_step_make_install() {
	install -Dm755 murex \
		"${TERMUX_PREFIX}/bin/murex"
}

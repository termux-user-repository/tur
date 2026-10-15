TERMUX_PKG_HOMEPAGE=https://github.com/lmorg/murex
TERMUX_PKG_DESCRIPTION="Murex: A Smarter Shell"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@everywhereless"
TERMUX_PKG_VERSION="7.3.1232"
TERMUX_PKG_SRCURL="https://github.com/lmorg/murex/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=a907bea8e343c3c3627fe4934233f352de2cc0f87d53230745534bd8f0037de4
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

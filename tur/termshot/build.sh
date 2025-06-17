TERMUX_PKG_HOMEPAGE="https://github.com/homeport/termshot"
TERMUX_PKG_DESCRIPTION="A utility to create terminal screenshots with style"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@Veha0001"
TERMUX_PKG_VERSION="1.4.0"
TERMUX_PKG_SRCURL="https://github.com/homeport/termshot/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256="ddcbf5e4b3b2b9eb19b4c93c4d6e9cc4e5f2c9e7f344b0e076c2e610cb803581"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_DEPENDS="imagemagick"

termux_step_pre_configure() {
	termux_setup_golang
}

termux_step_make() {
	go build -trimpath -o termshot ./cmd/termshot
}

termux_step_make_install() {
	install -Dm700 termshot "${TERMUX_PREFIX}/bin/termshot"
}

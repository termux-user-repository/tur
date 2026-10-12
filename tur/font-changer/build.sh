TERMUX_PKG_HOMEPAGE=https://github.com/GeneralKaos666/font-changer
TERMUX_PKG_DESCRIPTION="Font changer for Termux with Nerd Fonts"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="GeneralKaos666 <GeneralKaos666@users.noreply.github.com>"
TERMUX_PKG_VERSION="0.3.0"
TERMUX_PKG_SRCURL="https://github.com/GeneralKaos666/font-changer/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=a4acfe4d524e071475ded33e3d808bae3a6b048b79066cc6e0fd2df01a792d90
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_make() {
	termux_setup_golang

	go build -ldflags "-s -w -X main.version=v${TERMUX_PKG_VERSION}" \
		-o font-changer ./cmd/font-changer
}

termux_step_make_install() {
	install -Dm700 font-changer -t "${TERMUX_PREFIX}/bin/"
}

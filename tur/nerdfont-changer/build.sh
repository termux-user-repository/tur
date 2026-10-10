TERMUX_PKG_HOMEPAGE=https://github.com/GeneralKaos666/nerdfont-changer
TERMUX_PKG_DESCRIPTION="Fullscreen TUI picker to browse and change your Termux terminal font"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@GeneralKaos666"
TERMUX_PKG_VERSION="0.2.0"
TERMUX_PKG_SRCURL=https://github.com/GeneralKaos666/nerdfont-changer/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=b880d822e315a9a74d6fb65f04178b0df8527b631f18512f54bf84b784b1ff6f
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_make() {
	termux_setup_golang

	go build -ldflags "-s -w -X main.version=v${TERMUX_PKG_VERSION}" \
		-o nerdfont-changer ./cmd/nerdfont-changer
}

termux_step_make_install() {
	install -Dm700 nerdfont-changer -t "${TERMUX_PREFIX}/bin/"
}

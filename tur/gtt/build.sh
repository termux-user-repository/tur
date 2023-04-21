TERMUX_PKG_HOMEPAGE=https://github.com/eeeXun/GTT
TERMUX_PKG_DESCRIPTION="Google Translate TUI (Originally). Now support ArgosTranslate, GoogleTranslate."
# XXX: Upstream doesn't provide a license, so use the READMD
TERMUX_PKG_LICENSE="custom"
TERMUX_PKG_LICENSE_FILE="README.md"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="5"
TERMUX_PKG_SRCURL=https://github.com/eeeXun/GTT/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=1469fc7552537b96a533917449caddc27a23ffb55e877679648e00961683b693
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	termux_setup_golang

	go mod init || :
	go mod tidy
}

termux_step_make() {
	go build -ldflags="-s -w -X main.version=$TERMUX_PKG_VERSION"
}

termux_step_make_install() {
	install -Dm700 -t "${TERMUX_PREFIX}"/bin "$TERMUX_PKG_SRCDIR"/gtt
}

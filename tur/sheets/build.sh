TERMUX_PKG_HOMEPAGE=https://github.com/maaslalani/sheets
TERMUX_PKG_DESCRIPTION="Terminal based spreadsheet tool"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="Gouranga Das Samrat <gouranga.das.khulna@gmail.com>"
TERMUX_PKG_VERSION="0.3.0"
TERMUX_PKG_SRCURL="https://github.com/maaslalani/sheets/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=d65b37c4d40c0a531a87a81848350528387e1247b24d2aa3a04dd5a41338c9fa
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_make() {
	termux_setup_golang

	go build -trimpath -ldflags="-s -w" -o sheets .
}

termux_step_make_install() {
	install -Dm700 sheets "$TERMUX_PREFIX/bin/sheets"
}

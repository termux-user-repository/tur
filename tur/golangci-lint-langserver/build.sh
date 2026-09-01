TERMUX_PKG_HOMEPAGE=https://github.com/nametake/golangci-lint-langserver
TERMUX_PKG_DESCRIPTION="Language server for golangci-lint"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="Gouranga Das Samrat <gouranga.das.khulna@gmail.com>"
TERMUX_PKG_VERSION="0.0.11"
TERMUX_PKG_SRCURL=https://github.com/nametake/golangci-lint-langserver/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=d9f1fc02861eeb9ce60c89e79be706d7ec636f653d5039a76857b18cb98875fb
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_make() {
	termux_setup_golang

	go build -o golangci-lint-langserver .
}

termux_step_make_install() {
	install -Dm755 -t "$TERMUX_PREFIX/bin" "$TERMUX_PKG_SRCDIR/golangci-lint-langserver"
}

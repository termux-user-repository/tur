TERMUX_PKG_HOMEPAGE=https://github.com/nametake/golangci-lint-langserver
TERMUX_PKG_DESCRIPTION="Language server for golangci-lint"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="Gouranga Das Samrat <gouranga.das.khulna@gmail.com>"
TERMUX_PKG_VERSION="0.0.12"
TERMUX_PKG_SRCURL=https://github.com/nametake/golangci-lint-langserver/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=bdda9b1138f0a6cbfec0b2a93ef64111410bf16a82583c659e1b57f11ed93936
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_make() {
	termux_setup_golang

	go build -o golangci-lint-langserver .
}

termux_step_make_install() {
	install -Dm755 -t "$TERMUX_PREFIX/bin" "$TERMUX_PKG_SRCDIR/golangci-lint-langserver"
}

TERMUX_PKG_HOMEPAGE=https://patchsplit.zitzhen.cn
TERMUX_PKG_DESCRIPTION="A CLI tool for splitting patch files into per-commit patches"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="Oliver Lin <oliver@liuxiaozhen.dev>"
TERMUX_PKG_VERSION="1.4.0"
TERMUX_PKG_SRCURL="https://github.com/zitzhen/patchsplit/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=477eb6a6b96d169ba15a0a0ea364846e38e024d2529d362c44356f821e06e993
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_DEPENDS="curl, git"

termux_step_make() {
	termux_setup_rust

	cargo build \
		--jobs "$TERMUX_PKG_MAKE_PROCESSES" \
		--target "$CARGO_TARGET_NAME" \
		--release
}

termux_step_make_install() {
	install -Dm755 \
		"$TERMUX_PKG_SRCDIR/target/$CARGO_TARGET_NAME/release/patchsplit" \
		"$TERMUX_PREFIX/bin/patchsplit"
}

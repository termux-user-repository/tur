TERMUX_PKG_HOMEPAGE=https://github.com/mesamirh/MovieBox-Tui
TERMUX_PKG_DESCRIPTION="Terminal client for streaming movies, series, and anime"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@mesamirh"
TERMUX_PKG_VERSION="0.1.13"
TERMUX_PKG_SRCURL=https://github.com/mesamirh/MovieBox-Tui/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=ca58d0966b0f180b5dd650335d9d3caf276a7a3563cc87b92030b79372c8c536
TERMUX_PKG_DEPENDS="openssl, pkg-config"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_make() {
	termux_setup_rust
	cargo build --jobs $TERMUX_PKG_MAKE_PROCESSES --target $CARGO_TARGET_NAME --release
}

termux_step_make_install() {
	install -Dm700 -t $TERMUX_PREFIX/bin target/${CARGO_TARGET_NAME}/release/moviebox-tui
}

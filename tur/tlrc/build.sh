TERMUX_PKG_HOMEPAGE=https://github.com/tldr-pages/tlrc
TERMUX_PKG_DESCRIPTION="Official tldr client written in Rust"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@everywhereless"
TERMUX_PKG_VERSION="1.13.1"
TERMUX_PKG_SRCURL="https://github.com/tldr-pages/tlrc/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=4b85b85c0299ae2ae6b78d2d52b2e597e1441da24b579034780663e33ccc85fc
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_REPLACES="tealdeer"
TERMUX_PKG_CONFLICTS="tealdeer"

termux_step_pre_configure() {
	termux_setup_rust
}

termux_step_make() {
	cargo build \
		--jobs "$TERMUX_PKG_MAKE_PROCESSES" \
		--target "$CARGO_TARGET_NAME" \
		--release
}

termux_step_make_install() {
	install -Dm755 \
		"target/${CARGO_TARGET_NAME}/release/tldr" \
		"${TERMUX_PREFIX}/bin/tldr"
}

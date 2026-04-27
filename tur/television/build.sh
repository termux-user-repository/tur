TERMUX_PKG_HOMEPAGE=https://github.com/alexpasmantier/television
TERMUX_PKG_DESCRIPTION="A very fast, portable and hackable fuzzy finder"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@everywhereless"
TERMUX_PKG_VERSION="0.15.7"
TERMUX_PKG_SRCURL="https://github.com/alexpasmantier/television/archive/refs/tags/${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=e30bc41b074565093099d4a4403465f3f6d3e852af22ab423348b9dbe211d8c1
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

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
		"target/${CARGO_TARGET_NAME}/release/tv" \
		"${TERMUX_PREFIX}/bin/tv"
}

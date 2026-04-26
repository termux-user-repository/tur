TERMUX_PKG_HOMEPAGE=https://github.com/bahdotsh/feedr
TERMUX_PKG_DESCRIPTION="A feature-rich terminal-based RSS/Atom feed re
ader written in Rust"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@everywhereless"
TERMUX_PKG_VERSION="0.7.0"
TERMUX_PKG_SRCURL="https://github.com/bahdotsh/feedr/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=cffd8e06d9c0e69fc3774cb839ac927bd26d3587c3027181f0a35fd95d43bdd9
TERMUX_PKG_DEPENDS="openssl"
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
		"target/${CARGO_TARGET_NAME}/release/feedr" \
		"${TERMUX_PREFIX}/bin/feedr"
}

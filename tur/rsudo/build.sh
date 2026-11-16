TERMUX_PKG_HOMEPAGE=https://github.com/Wiltxxx/RSudo
TERMUX_PKG_DESCRIPTION="A high-performance sudo alternative for Termux, written in Rust"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@Wiltxxx"
TERMUX_PKG_VERSION=0.1.0
TERMUX_PKG_SRCURL=https://github.com/Wiltxxx/RSudo/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=36ff98dd7af3aa571cbab650b0a38fe4dfe6be357408094e3bb124c7d8953884
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_pre_configure() {
	termux_setup_rust
}

termux_step_make() {
	cargo build --release --target "${CARGO_TARGET_NAME}" --locked
}

termux_step_make_install() {
	install -Dm755 "target/${CARGO_TARGET_NAME}/release/rsudo" \
		"${TERMUX_PREFIX}/bin/rsudo"
}

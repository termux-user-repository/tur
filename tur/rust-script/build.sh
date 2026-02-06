TERMUX_PKG_HOMEPAGE=https://rust-script.org/
TERMUX_PKG_DESCRIPTION="Run Rust files and expressions as scripts without any setup or compilation step"
TERMUX_PKG_LICENSE="Apache-2.0, MIT"
TERMUX_PKG_LICENSE_FILE="LICENSE-APACHE, LICENSE-MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="0.36.0"
TERMUX_PKG_DEPENDS="rust"
TERMUX_PKG_ANTI_BUILD_DEPENDS="rust"
TERMUX_PKG_SRCURL=https://github.com/fornwall/rust-script/archive/refs/tags/$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=9b6d04ad4dd34838c1b55a8ec4b69e8d7f3008a67d85ef1c35b49502c359b6d8
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_pre_configure() {
	termux_setup_rust
}

termux_step_make() {
	cargo build --jobs "$TERMUX_PKG_MAKE_PROCESSES" --target "$CARGO_TARGET_NAME" --release
}

termux_step_make_install() {
	install -Dm700 -t "$TERMUX_PREFIX/bin" "target/${CARGO_TARGET_NAME}/release/rust-script"
}

TERMUX_PKG_HOMEPAGE=https://github.com/rvben/rumdl
TERMUX_PKG_DESCRIPTION="Markdown Linter and Formatter written in Rust"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="0.2.22"
TERMUX_PKG_SRCURL="https://github.com/rvben/rumdl/archive/refs/tags/v$TERMUX_PKG_VERSION.tar.gz"
TERMUX_PKG_SHA256=ffa94130a747cac3668593e8919b836369384be32ae963650ab972c39db25b69
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_pre_configure() {
	termux_setup_rust
}

termux_step_make() {
	cargo build --jobs "$TERMUX_PKG_MAKE_PROCESSES" --target "$CARGO_TARGET_NAME" --release
}

termux_step_make_install() {
	install -Dm755 -t "$TERMUX_PREFIX/bin" "target/$CARGO_TARGET_NAME/release/$TERMUX_PKG_NAME"
}

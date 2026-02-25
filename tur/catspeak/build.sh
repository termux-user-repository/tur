TERMUX_PKG_HOMEPAGE=https://github.com/SchweGELBin/catspeak
TERMUX_PKG_DESCRIPTION="Cowsay like program of a speaking cat"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@SchweGELBin"
TERMUX_PKG_VERSION=1.2.3
TERMUX_PKG_SRCURL=https://github.com/SchweGELBin/catspeak/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=393879f16e385a28d80cbd10c35d65b8e56b7de1c3798cce792e25901a88c451
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_pre_configure() {
	termux_setup_rust
}

termux_step_make() {
	cargo build --jobs "$TERMUX_PKG_MAKE_PROCESSES" --target "$CARGO_TARGET_NAME" --release
}

termux_step_make_install() {
	install -Dm700 -t "$TERMUX_PREFIX/bin" "target/${CARGO_TARGET_NAME}/release/${TERMUX_PKG_NAME}"
}

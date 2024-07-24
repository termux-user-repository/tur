TERMUX_PKG_HOMEPAGE="https://github.com/BurntSushi/xsv"
TERMUX_PKG_DESCRIPTION="CSV/TSV manipulation utility in Rust"
TERMUX_PKG_LICENSE="MIT, Unlicense"
TERMUX_PKG_LICENSE_FILE="LICENSE-MIT, UNLICENSE, COPYING"
TERMUX_PKG_MAINTAINER="@flosnvjx"
TERMUX_PKG_VERSION="0.13.0"
TERMUX_PKG_SRCURL="https://github.com/BurntSushi/xsv/archive/refs/tags/$TERMUX_PKG_VERSION.tar.gz"
TERMUX_PKG_SHA256=2b75309b764c9f2f3fdc1dd31eeea5a74498f7da21ae757b3ffd6fd537ec5345
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_make() {
	termux_setup_rust
	cargo build --jobs $TERMUX_PKG_MAKE_PROCESSES --target $CARGO_TARGET_NAME --release --locked
}

termux_step_make_install() {
	install -Dm700 -t $TERMUX_PREFIX/bin target/${CARGO_TARGET_NAME}/release/xsv
	install -Dm600 -t $TERMUX_PREFIX/share/doc/$TERMUX_PKG_NAME README.*
}

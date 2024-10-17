TERMUX_PKG_HOMEPAGE="https://git.average.name/AverageHelper/ograph-rs"
TERMUX_PKG_DESCRIPTION="A simple command-line utility to extract and print OpenGraph metadata from a given URL."
TERMUX_PKG_LICENSE="GPL-3.0-or-later"
TERMUX_PKG_MAINTAINER="@AverageHelper"
TERMUX_PKG_VERSION="0.3.0"
TERMUX_PKG_SRCURL="https://git.average.name/AverageHelper/ograph-rs/archive/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=b0238ba2a24804bef64730cf35c25dd955ab355f607ad25bd8c3b666c5272c38
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_pre_configure() {
	termux_setup_rust
}

termux_step_make() {
	cargo build --jobs $TERMUX_PKG_MAKE_PROCESSES --target $CARGO_TARGET_NAME --release --locked
}

termux_step_make_install() {
	install -Dm700 -t $TERMUX_PREFIX/bin target/${CARGO_TARGET_NAME}/release/ograph
	install -Dm600 -t $TERMUX_PREFIX/share/doc/$TERMUX_PKG_NAME README.*
}

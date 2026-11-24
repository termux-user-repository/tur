TERMUX_PKG_HOMEPAGE=https://github.com/lev73748/akg
TERMUX_PKG_DESCRIPTION="Fast package manager for Termux written in Rust"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@lev73748"
TERMUX_PKG_VERSION="0.5.8"
TERMUX_PKG_SRCURL=https://github.com/lev73748/akg/archive/refs/tags/0.5.8.tar.gz
TERMUX_PKG_SHA256=b31f589340840b25fbc14f108763666c6b01036f02873bbf6a213f3a141a3c42
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_VERSION_REGEXP="\d+\.\d+\.\d+"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_DEPENDS="gpgv, termux-keyring"

termux_step_pre_configure() {
	termux_setup_rust
}

termux_step_make() {
	cargo build --jobs $TERMUX_PKG_MAKE_PROCESSES --target $CARGO_TARGET_NAME --release
}

termux_step_make_install() {
	install -Dm700 -t $TERMUX_PREFIX/bin target/${CARGO_TARGET_NAME}/release/akg
}

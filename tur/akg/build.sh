TERMUX_PKG_HOMEPAGE=https://github.com/lev73748/akg
TERMUX_PKG_DESCRIPTION="Fast package manager for Termux written in Rust"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@lev73748"
TERMUX_PKG_VERSION="0.5.7"
TERMUX_PKG_SRCURL=https://github.com/lev73748/akg/archive/refs/tags/0.5.7.tar.gz
TERMUX_PKG_SHA256=e73de42d249e48ada9e718d04b0cf4808791c76107a8584647538e7e00c1bef5
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

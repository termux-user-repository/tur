TERMUX_PKG_HOMEPAGE=https://github.com/yannjor/krabby
TERMUX_PKG_DESCRIPTION="Print pokemon sprites in your terminal"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@SunPodder"
TERMUX_PKG_VERSION="0.1.7"
TERMUX_PKG_SRCURL="https://github.com/yannjor/krabby/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=a26345f3146eed0692996c0e5bf15d7091bc69d49f282e26ba172db9957f518c
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_make() {
	termux_setup_rust
	cargo build --jobs $TERMUX_MAKE_PROCESSES --target $CARGO_TARGET_NAME --release
}

termux_step_make_install() {
	install -Dm755 -t $TERMUX_PREFIX/bin target/${CARGO_TARGET_NAME}/release/krabby
}


TERMUX_PKG_HOMEPAGE=https://github.com/yannjor/krabby
TERMUX_PKG_DESCRIPTION="Print pokemon sprites in your terminal"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@SunPodder"
TERMUX_PKG_VERSION="0.1.8"
TERMUX_PKG_SRCURL="https://github.com/yannjor/krabby/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=4c85ba58ba2db911ecb2e236bebf5a74bdf2d31f9c687849f3961170ccf945de
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_make() {
	termux_setup_rust
	cargo build --jobs $TERMUX_MAKE_PROCESSES --target $CARGO_TARGET_NAME --release
}

termux_step_make_install() {
	install -Dm755 -t $TERMUX_PREFIX/bin target/${CARGO_TARGET_NAME}/release/krabby
}


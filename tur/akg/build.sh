TERMUX_PKG_HOMEPAGE=https://github.com/lev73748/akg
TERMUX_PKG_DESCRIPTION="Fast package manager for Termux"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@lev73748"
TERMUX_PKG_VERSION="0.5.5"
TERMUX_PKG_SRCURL=https://github.com/lev73748/akg/archive/refs/tags/${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=5d1a7628cc4c7357c4aab3104374bbad4ad3a7e3d114eec5be760ac1f761fb7c
TERMUX_PKG_AUTO_UPDATE=false
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_pre_configure() {
	termux_setup_rust
}

termux_step_make() {
	cargo build --jobs "$TERMUX_PKG_MAKE_PROCESSES" \
		--target "$CARGO_TARGET_NAME" --release
}

termux_step_make_install() {
	install -Dm755 -t "$TERMUX_PREFIX/bin" \
		"target/${CARGO_TARGET_NAME}/release/akg"
}

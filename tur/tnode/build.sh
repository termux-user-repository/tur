TERMUX_PKG_HOMEPAGE=https://github.com/Irithell/tnode
TERMUX_PKG_DESCRIPTION="POSIX compatibility shim for Android SDCARD filesystem — LD_PRELOAD bridge for Node.js, Python, Ruby, C and C++ runtimes in Termux"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@Irithell"
TERMUX_PKG_VERSION="0.1.4"
TERMUX_PKG_SRCURL=https://github.com/Irithell/tnode/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=720509789e5eb17b79e624582666d97faf835d40927947060808e88f4a6b5b60
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_pre_configure() {
	termux_setup_rust
}

termux_step_make() {
	cargo build \
		--target "$CARGO_TARGET_NAME" \
		--release \
		--locked
}

termux_step_make_install() {
	install -Dm755 "target/${CARGO_TARGET_NAME}/release/tnode" \
		"${TERMUX_PREFIX}/bin/tnode"

	install -Dm644 "target/${CARGO_TARGET_NAME}/release/libthook.so" \
		"${TERMUX_PREFIX}/lib/libthook.so"
}

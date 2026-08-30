TERMUX_PKG_HOMEPAGE=https://github.com/GpuZelenograd/memtest_vulkan
TERMUX_PKG_DESCRIPTION="Vulkan compute tool for testing video memory stability"
TERMUX_PKG_LICENSE="ZLIB"
TERMUX_PKG_MAINTAINER="わたあめえ <wataamee777@gmail.com>"
TERMUX_PKG_VERSION=0.5.0
TERMUX_PKG_SRCURL=https://github.com/GpuZelenograd/memtest_vulkan/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=ec7100c94d92e0d5f5357386f144dc33ec428890f5dc0d7925e9b1f09cb58e5e
TERMUX_PKG_DEPENDS="vulkan-loader-generic"
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_make() {
	termux_setup_rust

	cargo build --jobs $TERMUX_PKG_MAKE_PROCESSES --target $CARGO_TARGET_NAME --release
}

termux_step_make_install() {
	install -Dm755 -t $TERMUX_PREFIX/bin target/$CARGO_TARGET_NAME/release/memtest_vulkan
}

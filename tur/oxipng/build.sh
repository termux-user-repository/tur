TERMUX_PKG_HOMEPAGE="https://github.com/oxipng/oxipng"
TERMUX_PKG_DESCRIPTION="Multithreaded PNG optimizer written in Rust"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="10.2.0"
TERMUX_PKG_SRCURL=https://github.com/oxipng/oxipng/archive/refs/tags/v$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=0d0da5f245ed3a669bce63d3ca368d476bae67b0014a927c00df912c9d964a44
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	termux_setup_rust
}

termux_step_make() {
	cargo build --jobs $TERMUX_PKG_MAKE_PROCESSES --target $CARGO_TARGET_NAME --release
}

termux_step_make_install() {
	install -Dm755 -t $TERMUX_PREFIX/bin target/${CARGO_TARGET_NAME}/release/oxipng
}

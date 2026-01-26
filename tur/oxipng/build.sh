TERMUX_PKG_HOMEPAGE="https://github.com/oxipng/oxipng"
TERMUX_PKG_DESCRIPTION="Multithreaded PNG optimizer written in Rust"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="10.1.0"
TERMUX_PKG_SRCURL=https://github.com/oxipng/oxipng/archive/refs/tags/v$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=6c5e1d021a844ba730193943ab63ad99e7d9f1089c36f3db59014517ea99cf99
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

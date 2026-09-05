TERMUX_PKG_HOMEPAGE=https://github.com/mesamirh/MovieBox-Tui
TERMUX_PKG_DESCRIPTION="Terminal client for streaming movies, series, and anime"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@mesamirh"
TERMUX_PKG_VERSION="0.1.16"
TERMUX_PKG_SRCURL=https://github.com/mesamirh/MovieBox-Tui/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=f2d0669fdefabd97511500d107222ba2f05ae48ffd0e634344890f5ddb3780eb
TERMUX_PKG_DEPENDS="openssl, pkg-config"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_make() {
	termux_setup_rust
	cargo build --jobs $TERMUX_PKG_MAKE_PROCESSES --target $CARGO_TARGET_NAME --release
}

termux_step_make_install() {
	install -Dm700 -t $TERMUX_PREFIX/bin target/${CARGO_TARGET_NAME}/release/moviebox-tui
}

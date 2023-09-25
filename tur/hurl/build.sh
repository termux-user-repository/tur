TERMUX_PKG_HOMEPAGE=https://github.com/Orange-OpenSource/hurl
TERMUX_PKG_DESCRIPTION="Hurl, run and test HTTP requests with plain text"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@SunPodder"
TERMUX_PKG_VERSION="4.1.0"
TERMUX_PKG_SRCURL="https://github.com/Orange-OpenSource/hurl/archive/refs/tags/${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=3356f64158e6dc5f2e29c37eee80a43332b1734baa7380356affeb5160ffca09
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_BUILD_DEPENDS="openssl, libxml2"

termux_step_make() {
	termux_setup_rust
	cargo build --jobs $TERMUX_MAKE_PROCESSES --target $CARGO_TARGET_NAME --release
}

termux_step_make_install() {
	install -Dm755 -t $TERMUX_PREFIX/bin target/${CARGO_TARGET_NAME}/release/hurl
	install -Dm755 -t $TERMUX_PREFIX/bin target/${CARGO_TARGET_NAME}/release/hurlfmt
}

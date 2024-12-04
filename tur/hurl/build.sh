TERMUX_PKG_HOMEPAGE=https://github.com/Orange-OpenSource/hurl
TERMUX_PKG_DESCRIPTION="Hurl, run and test HTTP requests with plain text"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@SunPodder"
TERMUX_PKG_VERSION="6.0.0"
TERMUX_PKG_SRCURL="https://github.com/Orange-OpenSource/hurl/archive/refs/tags/${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=3f21c9e2a4e86e1a5913e211d890b07e9388871e3d6ed526668487f56b11b925
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_BUILD_DEPENDS="openssl, libxml2"

termux_step_make() {
	termux_setup_rust
	cargo build --jobs $TERMUX_PKG_MAKE_PROCESSES --target $CARGO_TARGET_NAME --release
}

termux_step_make_install() {
	install -Dm755 -t $TERMUX_PREFIX/bin target/${CARGO_TARGET_NAME}/release/hurl
	install -Dm755 -t $TERMUX_PREFIX/bin target/${CARGO_TARGET_NAME}/release/hurlfmt
}

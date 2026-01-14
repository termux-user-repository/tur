TERMUX_PKG_HOMEPAGE="https://playit.gg"
TERMUX_PKG_DESCRIPTION="playit is a global proxy that allows anyone to host a server without port forwarding."
TERMUX_PKG_LICENSE="BSD 2-Clause"
TERMUX_PKG_MAINTAINER="@nisheri-ascar"
TERMUX_PKG_VERSION="0.17.1"
_REAL_VERSION="${TERMUX_PKG_VERSION/\~/-}"
TERMUX_PKG_SRCURL=https://github.com/playit-cloud/playit-agent/archive/v${_REAL_VERSION}.tar.gz
TERMUX_PKG_SHA256=d8c937325d9415d2d73c91b3dda8da3919a5dedf3ea8d831716e00924d32d832
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	termux_setup_rust
}

termux_step_make() {
	cargo build --jobs $TERMUX_PKG_MAKE_PROCESSES --target $CARGO_TARGET_NAME --release
}

termux_step_make_install() {
	install -Dm755 -t $TERMUX_PREFIX/bin target/${CARGO_TARGET_NAME}/release/playit-cli
}

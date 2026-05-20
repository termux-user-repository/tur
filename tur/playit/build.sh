TERMUX_PKG_HOMEPAGE="https://playit.gg"
TERMUX_PKG_DESCRIPTION="playit is a global proxy that allows anyone to host a server without port forwarding."
TERMUX_PKG_LICENSE="BSD 2-Clause"
TERMUX_PKG_MAINTAINER="@nisheri-ascar"
TERMUX_PKG_VERSION="1.0.4"
_REAL_VERSION="${TERMUX_PKG_VERSION/\~/-}"
TERMUX_PKG_SRCURL=https://github.com/playit-cloud/playit-agent/archive/v${_REAL_VERSION}.tar.gz
TERMUX_PKG_SHA256=06620b864c8b41ec6d2a752237936e55da10aafc34f8d5b236b1ff8e8a779596
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

TERMUX_PKG_HOMEPAGE=https://github.com/horizonwiki/fire
TERMUX_PKG_DESCRIPTION="Terminal fire animation written in Rust"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_VERSION=0.1.2
TERMUX_PKG_MAINTAINER="@horizonwiki"
TERMUX_PKG_SRCURL=https://github.com/horizonwiki/fire/archive/refs/tags/${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=b4f299ba7075b92a94198d31279cffae3d922bd9366ac139ccb8b93e5ce07f7e
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true
termux_step_make_install() {
    termux_setup_rust
    
    cargo build --release

    install -Dm755 target/release/fire-cli $TERMUX_PREFIX/bin/fire-cli
}
TERMUX_PKG_HOMEPAGE="https://github.com/Manash07Bhoi/OmniCLI"
TERMUX_PKG_DESCRIPTION="Professional-grade CLI toolkit in Rust - file ops, full-text search, archives, age encryption"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@Manash07Bhoi"
TERMUX_PKG_VERSION="0.1.1"
TERMUX_PKG_SRCURL="https://github.com/Manash07Bhoi/OmniCLI/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=9732f3b96f51246f878d00af15c2245f8df6cdc62535dfb067b82e6e63614a6c
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_DEPENDS=""

termux_step_make() {
    termux_setup_rust
    cargo build --jobs $TERMUX_PKG_MAKE_PROCESSES --target $CARGO_TARGET_NAME --release --manifest-path omnicli/Cargo.toml --locked
}

termux_step_make_install() {
    install -Dm755 -t $TERMUX_PREFIX/bin omnicli/target/${CARGO_TARGET_NAME}/release/omnicli
    install -Dm644 -t "$TERMUX_PREFIX/share/doc/$TERMUX_PKG_NAME/" README*
}

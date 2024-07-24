TERMUX_PKG_HOMEPAGE=https://github.com/clbarnes/detchar
TERMUX_PKG_DESCRIPTION="Minimal CLI utility of chardetng crate, which is a successor to universalchardet (uchardet)"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@flosnvjx"
TERMUX_PKG_VERSION=0.1.0
TERMUX_PKG_SRCURL="https://github.com/clbarnes/detchar/archive/refs/tags/v$TERMUX_PKG_VERSION.tar.gz"
TERMUX_PKG_SHA256=5d2404dcdcd22b0f4fc8a2f43f22b7c42a7dbd1dc40b3af7e0dbeebc21228d37
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_TAG_TYPE="newest-tag"

termux_step_make() {
	termux_setup_rust
	cargo build --jobs $TERMUX_PKG_MAKE_PROCESSES --target $CARGO_TARGET_NAME --release --locked
}

termux_step_make_install() {
	install -Dm700 -t $TERMUX_PREFIX/bin target/${CARGO_TARGET_NAME}/release/detchar
	install -Dm600 -t $TERMUX_PREFIX/share/doc/$TERMUX_PKG_NAME README.*
}

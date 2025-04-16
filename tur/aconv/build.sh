TERMUX_PKG_HOMEPAGE="https://github.com/kena0ki/aconv"
TERMUX_PKG_DESCRIPTION="Like iconv(1), but automatically detect input text encoding"
TERMUX_PKG_LICENSE="MIT, Apache-2.0"
TERMUX_PKG_MAINTAINER="@flosnvjx"
TERMUX_PKG_VERSION="0.1.4"
TERMUX_PKG_SRCURL="git+https://github.com/kena0ki/aconv.git/"
TERMUX_PKG_SHA256=SKIP_CHECKSUM
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_GIT_BRANCH=main
_COMMIT=3f5b5e6f944b36d161570e70280a5cadd78f6790

termux_step_post_get_source() {
	git fetch --unshallow
	git checkout $_COMMIT
}

termux_step_make() {
	termux_setup_rust
	cargo build --jobs $TERMUX_PKG_MAKE_PROCESSES --target $CARGO_TARGET_NAME --release
}

termux_step_make_install() {
	install -Dm755 -t $TERMUX_PREFIX/bin target/${CARGO_TARGET_NAME}/release/aconv
	install -Dm644 -t "$TERMUX_PREFIX/share/doc/$TERMUX_PKG_NAME/" README*
}

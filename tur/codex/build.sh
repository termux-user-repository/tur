TERMUX_PKG_HOMEPAGE=https://github.com/openai/codex
TERMUX_PKG_DESCRIPTION="Lightweight coding agent that runs in your terminal"
TERMUX_PKG_LICENSE="Apache-2.0, MIT"
TERMUX_PKG_LICENSE_FILE="../LICENSE, ../NOTICE"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="0.86.0"
TERMUX_PKG_SRCURL="https://github.com/openai/codex/archive/refs/tags/rust-v$TERMUX_PKG_VERSION.tar.gz"
TERMUX_PKG_SHA256=affd839ee51462bf833500319a5d6dfeb30c76e862be1e6fb6fe170fcfc49cf4
TERMUX_PKG_DEPENDS="libc++, openssl"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_VERSION_SED_REGEXP='s/rust-v//'
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_configure() {
	TERMUX_PKG_SRCDIR+="/codex-rs"
	TERMUX_PKG_BUILDDIR+="/codex-rs"
}

termux_step_make() {
	termux_setup_rust

	cargo build \
		-p codex-cli \
		--release \
		--jobs $TERMUX_PKG_MAKE_PROCESSES \
		--target $CARGO_TARGET_NAME
}

termux_step_make_install() {
	install -Dm700 -t $TERMUX_PREFIX/bin target/${CARGO_TARGET_NAME}/release/codex

	rm -rf $TERMUX_PREFIX/share/doc/$TERMUX_PKG_NAME
	mkdir -p $TERMUX_PREFIX/share/doc/$TERMUX_PKG_NAME
	cp -Rfv ../docs/* $TERMUX_PREFIX/share/doc/$TERMUX_PKG_NAME/
}

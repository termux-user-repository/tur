TERMUX_PKG_HOMEPAGE=https://github.com/openai/codex
TERMUX_PKG_DESCRIPTION="Lightweight coding agent that runs in your terminal"
TERMUX_PKG_LICENSE="Apache-2.0, MIT"
TERMUX_PKG_LICENSE_FILE="../LICENSE, ../NOTICE"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="0.106.0"
TERMUX_PKG_SRCURL="https://github.com/openai/codex/archive/refs/tags/rust-v$TERMUX_PKG_VERSION.tar.gz"
TERMUX_PKG_SHA256=f6a6934f32c77d7d31a7ab2c491d061adb07e78a86b1bef2083030ec5274a5e4
TERMUX_PKG_DEPENDS="libc++, openssl"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_VERSION_SED_REGEXP='s/rust-v//'
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_pre_configure() {
	termux_setup_rust

	cd codex-rs

	: "${CARGO_HOME:=$HOME/.cargo}"
	export CARGO_HOME

	cargo vendor
	find ./vendor \
		-mindepth 1 -maxdepth 1 -type d \
		! -wholename ./vendor/cc \
		-exec rm -rf '{}' \;

	patch --silent -p1 \
		-d ./vendor/cc/ \
		< "$TERMUX_PKG_BUILDER_DIR"/rust-cc-do-not-concatenate-all-the-CFLAGS.diff

	sed -i '/\[patch.crates-io\]/a cc = { path = "./vendor/cc" }' Cargo.toml
}

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

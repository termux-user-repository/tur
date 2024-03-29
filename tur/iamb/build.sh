TERMUX_PKG_HOMEPAGE=https://iamb.chat/
TERMUX_PKG_DESCRIPTION="A terminal-based client for Matrix for the Vim addict"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=0.0.9
TERMUX_PKG_SRCURL="https://github.com/ulyssa/iamb/archive/refs/tags/v$TERMUX_PKG_VERSION.tar.gz"
TERMUX_PKG_SHA256=7ef6d23a957bfab62decd48caa83c106a49d95760b4b2ccf5a6b6a8f4506e687
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	termux_setup_rust

	if [ "$TERMUX_ARCH" = "x86_64" ]; then
		RUSTFLAGS+=" -C link-arg=$($CC -print-libgcc-file-name)"
	fi

	: "${CARGO_HOME:=$HOME/.cargo}"
	export CARGO_HOME

	rm -rf $CARGO_HOME/registry/src/index.crates.io-*/arboard-*
	cargo fetch --target "${CARGO_TARGET_NAME}"

	for d in $CARGO_HOME/registry/src/index.crates.io-*/arboard-*/; do
		patch --silent -p1 -d ${d} < "$TERMUX_PKG_BUILDER_DIR/0001-arboard-dummy-platform.diff"
	done
}

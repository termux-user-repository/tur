TERMUX_PKG_HOMEPAGE=https://iamb.chat/
TERMUX_PKG_DESCRIPTION="A terminal-based client for Matrix for the Vim addict"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=0.0.8
TERMUX_PKG_SRCURL="https://github.com/ulyssa/iamb/archive/refs/tags/v$TERMUX_PKG_VERSION.tar.gz"
TERMUX_PKG_SHA256=594dcc7403d3ee9b94b7d786f0d63f264b12b45b3f5bae4351548418d49b6bb4
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	termux_setup_rust
	export CFLAGS="${TARGET_CFLAGS}"
	local _CARGO_TARGET_LIBDIR="target/${CARGO_TARGET_NAME}/release/deps"
	mkdir -p $_CARGO_TARGET_LIBDIR
	if [ $TERMUX_ARCH = "i686" ]; then
		RUSTFLAGS+=" -C link-arg=-latomic"
	elif [ $TERMUX_ARCH = "x86_64" ]; then
		pushd $_CARGO_TARGET_LIBDIR
		local libgcc="$($CC -print-libgcc-file-name)"
		echo "INPUT($libgcc -l:libunwind.a)" >libgcc.so
		popd
	fi
	: "${CARGO_HOME:=$HOME/.cargo}"
	export CARGO_HOME

	rm -rf $CARGO_HOME/registry/src/index.crates.io-*/arboard-3.2.0
	cargo fetch --target "${CARGO_TARGET_NAME}"

	for d in $CARGO_HOME/registry/src/index.crates.io-*/arboard-3.2.0/; do
		patch --silent -p1 -d ${d} < "$TERMUX_PKG_BUILDER_DIR/0001-arboard-dummy-platform.diff"
	done
}

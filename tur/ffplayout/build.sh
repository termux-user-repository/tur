TERMUX_PKG_HOMEPAGE=https://ffplayout.github.io
TERMUX_PKG_DESCRIPTION="Rust and ffmpeg based playout"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="0.25.7"
TERMUX_PKG_SRCURL=git+https://github.com/ffplayout/ffplayout
TERMUX_PKG_DEPENDS="ffmpeg"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_TAG_TYPE="latest-release-tag"

termux_step_make() {
	termux_setup_rust
	termux_setup_nodejs

	scripts/man_create.sh
	pushd frontend
	npm install
	npm run build
	cp -r dist ../public
	popd

	unset CFLAGS

	if [ "$TERMUX_ARCH" == "x86_64" ]; then
		local env_host=$(printf $CARGO_TARGET_NAME | tr a-z A-Z | sed s/-/_/g)
		export CARGO_TARGET_${env_host}_RUSTFLAGS+=" -C link-arg=$($CC -print-libgcc-file-name)"
	fi

	cargo clean
	cargo build --jobs $TERMUX_PKG_MAKE_PROCESSES --release --target $CARGO_TARGET_NAME
}

termux_step_make_install() {
	install -Dm755 "target/$CARGO_TARGET_NAME/release/ffplayout" "$TERMUX_PREFIX/bin/ffplayout"
	install -Dm644 assets/ffplayout.1.gz "$TERMUX_PREFIX/share/man/man1/ffplayout.1.gz"
	install -Dm644 assets/logo.png "$TERMUX_PREFIX/share/ffplayout/logo.png"
	install -Dm644 README.md "$TERMUX_PREFIX/share/doc/ffplayout/README"
	cp -a public "$TERMUX_PREFIX/share/ffplayout/"
}

termux_step_create_debscripts() {
	cp -f "$TERMUX_PKG_SRCDIR"/debian/{postinst,postrm} .
}

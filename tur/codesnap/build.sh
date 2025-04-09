TERMUX_PKG_HOMEPAGE="https://github.com/mistricky/CodeSnap"
TERMUX_PKG_DESCRIPTION="Pure Rust tool to generate beautiful code snapshots, provide CLI and Library"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_LICENSE_FILE="LICENSE"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="0.10.7"
TERMUX_PKG_SRCURL="https://github.com/mistricky/CodeSnap/archive/refs/tags/v$TERMUX_PKG_VERSION.tar.gz"
TERMUX_PKG_SHA256=ec7839c074f11f5c8895a97c50c529bddf411c66a5dd92625fa874fd89c9cccf
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_pre_configure() {
	termux_setup_rust

	: "${CARGO_HOME:=$HOME/.cargo}"
	export CARGO_HOME

	cargo vendor
	patch --silent -p1 \
		-d ./vendor/arboard/ \
		< "$TERMUX_PKG_BUILDER_DIR"/arboard-dummy-platform.diff

	echo "" >> Cargo.toml
	echo '[patch.crates-io]' >> Cargo.toml
	echo 'arboard = { path = "./vendor/arboard" }' >> Cargo.toml
}

termux_step_make() {
	cargo build --jobs $TERMUX_PKG_MAKE_PROCESSES --target $CARGO_TARGET_NAME --release
}

termux_step_make_install() {
	install -Dm700 -t $TERMUX_PREFIX/bin target/${CARGO_TARGET_NAME}/release/codesnap

	install -Dm600 -t $TERMUX_PREFIX/share/doc/$TERMUX_PKG_NAME README.*
}

termux_step_post_make_install() {
	# Remove the vendor sources to save space
	rm -rf "$TERMUX_PKG_SRCDIR"/vendor
}

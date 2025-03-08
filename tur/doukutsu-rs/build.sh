TERMUX_PKG_HOMEPAGE=https://github.com/doukutsu-rs/doukutsu-rs
TERMUX_PKG_DESCRIPTION="A faithful and open-source remake of Cave Story's engine written in Rust"
# LICENSE: Modified MIT
TERMUX_PKG_LICENSE="custom"
TERMUX_PKG_LICENSE_FILE="LICENSE"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="0.102.0-beta7"
TERMUX_PKG_SRCURL=https://github.com/doukutsu-rs/doukutsu-rs/archive/refs/tags/$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=ce839289ea87fb727f1f82ff1dad6e8b691bdf73150215ad13c6beb65e3f4cb1
TERMUX_PKG_DEPENDS="libc++, sdl2, sdl2-image"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_TAG_TYPE="latest-release-tag"

termux_step_configure() {
	termux_setup_rust

	: "${CARGO_HOME:=$HOME/.cargo}"
	export CARGO_HOME

	cargo vendor
	find ./vendor \
		-mindepth 1 -maxdepth 1 -type d \
		! -wholename ./vendor/cpal \
		! -wholename ./vendor/webbrowser \
		-exec rm -rf '{}' \;

	patch --silent -p1 \
		-d ./vendor/cpal/ \
		< "$TERMUX_PKG_BUILDER_DIR"/9998-cpal-no-jni.diff

	patch --silent -p1 \
		-d ./vendor/webbrowser/ \
		< "$TERMUX_PKG_BUILDER_DIR"/9999-webbrowser-no-jni.diff

	echo "" >> Cargo.toml
	echo "[patch.crates-io]" >> Cargo.toml
	echo "webbrowser = { path = \"./vendor/webbrowser\" }" >> Cargo.toml
	echo "" >> Cargo.toml
	echo "[patch.\"https://github.com/doukutsu-rs/cpal\"]" >> Cargo.toml
	echo "cpal = { path = \"./vendor/cpal\" }" >> Cargo.toml

	local _deps="$(cargo tree --target=aarch64-linux-android)"
	if [ "$(echo $_deps | grep -E '(jni|ndk)')" != "" ]; then
		echo "Deps: $_deps"
		termux_error_exit "Please ensure no ndk/jni deps."
	fi
}

termux_step_make() {
	termux_setup_rust
	termux_setup_cmake

	cargo build --jobs $TERMUX_PKG_MAKE_PROCESSES --target $CARGO_TARGET_NAME --release
}

termux_step_make_install() {
	install -Dm700 -t $TERMUX_PREFIX/bin target/${CARGO_TARGET_NAME}/release/doukutsu-rs
}

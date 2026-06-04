TERMUX_PKG_HOMEPAGE=https://github.com/doukutsu-rs/doukutsu-rs
TERMUX_PKG_DESCRIPTION="A faithful and open-source remake of Cave Story's engine written in Rust"
# LICENSE: Modified MIT
TERMUX_PKG_LICENSE="custom"
TERMUX_PKG_LICENSE_FILE="LICENSE"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="1.0.0"
TERMUX_PKG_SRCURL="https://github.com/doukutsu-rs/doukutsu-rs/archive/refs/tags/$TERMUX_PKG_VERSION.tar.gz"
TERMUX_PKG_SHA256=9025b7dd8996c09c53e026ac31babc6d6a349b18b69eff662c49feb7e44f7d88
TERMUX_PKG_DEPENDS="alsa-lib, alsa-plugins, libc++, sdl2, sdl2-image, xdg-utils"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_TAG_TYPE="latest-release-tag"

termux_step_configure() {
	termux_setup_rust

	cargo vendor
	find ./vendor \
		-mindepth 1 -maxdepth 1 -type d \
		! -wholename ./vendor/cpal \
		! -wholename ./vendor/webbrowser \
		! -wholename ./vendor/open \
		-exec rm -rf '{}' \;

	find . -type f -print0 | \
		xargs -0 sed -i \
		-e 's|\\"android\\"|\\"dummy\\"|g' \
		-e 's|"android"|"dummy"|g' \
		-e 's|\\"linux\\"|\\"android\\"|g' \
		-e 's|"linux"|"android"|g'

	sed -i 's/xdg-open/xdg-utils-xdg-open/g' vendor/open/src/unix.rs

	echo "" >> Cargo.toml
	echo "[patch.crates-io]" >> Cargo.toml
	echo "webbrowser = { path = \"./vendor/webbrowser\" }" >> Cargo.toml
	echo "open = { path = \"./vendor/open\" }" >> Cargo.toml
	echo "" >> Cargo.toml
	echo "[patch.\"https://github.com/doukutsu-rs/cpal\"]" >> Cargo.toml
	echo "cpal = { path = \"./vendor/cpal\" }" >> Cargo.toml

	local _deps="$(cargo tree --target="$CARGO_TARGET_NAME")"
	if [ "$(echo $_deps | grep -E '(jni|ndk)')" != "" ]; then
		echo "Deps: $_deps"
		termux_error_exit "Please ensure no ndk/jni deps."
	fi
}

termux_step_make() {
	termux_setup_rust
	termux_setup_cmake

	cargo build --jobs "$TERMUX_PKG_MAKE_PROCESSES" --target "$CARGO_TARGET_NAME" --release
}

termux_step_make_install() {
	install -Dm700 -t "$TERMUX_PREFIX/bin" "target/${CARGO_TARGET_NAME}/release/doukutsu-rs"
}

termux_step_create_debscripts() {
	cat > postinst <<-EOF
	#!$TERMUX_PREFIX/bin/sh
	echo "To install the English translation, use these commands:"
	echo "  curl -O https://www.cavestory.one/downloads/cavestoryen.zip"
	echo "  unzip cavestoryen.zip"
	echo "  cd CaveStory"
	echo "  export CAVESTORY_DATA_DIR=\$(pwd)/data"
	echo "  pulseaudio -D --exit-idle-time=-1"
	echo "  doukutsu-rs"
	echo "Use your PulseAudio start command before launch to have sound."
	echo "doukutsu-rs does not automatically launch PulseAudio on its own,"
	echo "but will connect to it and play sound if it is running already."
	EOF
	chmod +x postinst
}

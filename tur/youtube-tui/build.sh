TERMUX_PKG_HOMEPAGE=https://tui.siri.ws/youtube
TERMUX_PKG_DESCRIPTION="An aesthetically pleasing YouTube TUI written in Rust"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="Gouranga Das Samrat <gouranga.das.khulna@gmail.com>"
TERMUX_PKG_VERSION="0.9.4"
TERMUX_PKG_SRCURL="https://github.com/Siriusmart/youtube-tui/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=ac31c7c0600c47509384df27f1af2c4ec6644de988a703ca13856b147c675934
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_DEPENDS="libsixel, mpv | mpv-x, openssl"
TERMUX_PKG_RECOMMENDS="yt-dlp"
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_pre_configure() {
	export OPENSSL_INCLUDE_DIR="${TERMUX_PREFIX}/include"
	export OPENSSL_LIB_DIR="${TERMUX_PREFIX}/lib"

	termux_setup_rust

	cargo vendor
	find ./vendor \
		-mindepth 1 -maxdepth 1 -type d \
		! -wholename ./vendor/sixel-sys \
		! -wholename ./vendor/rquickjs-sys \
		-exec rm -rf '{}' \;

	# sixel-sys tries to configure and build its bundled libsixel for the
	# host, which breaks cross-compilation. Skip that and link against
	# the libsixel package instead.
	sed -i 's/let testing_build = false;/let testing_build = true;/' \
		vendor/sixel-sys/build.rs

	# rquickjs-sys (via rustypipe) ships no pregenerated bindings for
	# Android targets, so reuse the Linux ones of the same pointer width.
	local _bindings_src
	case "${TERMUX_ARCH}" in
	aarch64) _bindings_src="aarch64-unknown-linux-gnu" ;;
	x86_64) _bindings_src="x86_64-unknown-linux-gnu" ;;
	arm | i686) _bindings_src="i686-unknown-linux-gnu" ;;
	*) termux_error_exit "Unsupported arch: ${TERMUX_ARCH}" ;;
	esac
	cp "vendor/rquickjs-sys/src/bindings/${_bindings_src}.rs" \
		"vendor/rquickjs-sys/src/bindings/${CARGO_TARGET_NAME}.rs"

	echo "" >> Cargo.toml
	echo '[patch.crates-io]' >> Cargo.toml
	echo 'sixel-sys = { path = "./vendor/sixel-sys" }' >> Cargo.toml
	echo 'rquickjs-sys = { path = "./vendor/rquickjs-sys" }' >> Cargo.toml
}

termux_step_make() {
	cargo build \
		--jobs "${TERMUX_PKG_MAKE_PROCESSES}" \
		--target "${CARGO_TARGET_NAME}" \
		--release
}

termux_step_make_install() {
	install -Dm700 -t "${TERMUX_PREFIX}/bin" \
		"target/${CARGO_TARGET_NAME}/release/${TERMUX_PKG_NAME}"
}

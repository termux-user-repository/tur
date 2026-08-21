TERMUX_PKG_HOMEPAGE=https://github.com/mesamirh/MovieBox-Tui
TERMUX_PKG_DESCRIPTION="Terminal client for streaming movies, series, and anime"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@mesamirh"
TERMUX_PKG_VERSION="0.1.13"
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=https://github.com/mesamirh/MovieBox-Tui/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=ca58d0966b0f180b5dd650335d9d3caf276a7a3563cc87b92030b79372c8c536
TERMUX_PKG_DEPENDS="openssl, pkg-config"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_make() {
	termux_setup_rust
  cargo vendor
	find ./vendor \
		-mindepth 1 -maxdepth 1 -type d \
		! -wholename ./vendor/rustls-platform-verifier \
		-exec rm -rf '{}' \;

	find vendor/rustls-platform-verifier -type f -print0 | \
		xargs -0 sed -i \
		-e 's|"android"|"disabling_this_because_it_is_for_building_an_apk"|g' \
		-e "s|ANDROID|DISABLING_THIS_BECAUSE_IT_IS_FOR_BUILDING_AN_APK|g" \
		-e 's|"linux"|"android"|g'

	echo "" >> Cargo.toml
	echo '[patch.crates-io]' >> Cargo.toml
	echo 'rustls-platform-verifier = { path = "./vendor/rustls-platform-verifier" }' >> Cargo.toml
	cargo build --jobs $TERMUX_PKG_MAKE_PROCESSES --target $CARGO_TARGET_NAME --release
}

termux_step_make_install() {
	install -Dm700 -t $TERMUX_PREFIX/bin target/${CARGO_TARGET_NAME}/release/moviebox-tui
}

TERMUX_PKG_HOMEPAGE="https://playit.gg"
TERMUX_PKG_DESCRIPTION="playit is a global proxy that allows anyone to host a server without port forwarding."
TERMUX_PKG_LICENSE="BSD 2-Clause"
TERMUX_PKG_MAINTAINER="@nisheri-ascar"
TERMUX_PKG_VERSION="1.0.6"
_REAL_VERSION="${TERMUX_PKG_VERSION/\~/-}"
TERMUX_PKG_SRCURL=https://github.com/playit-cloud/playit-agent/archive/v${_REAL_VERSION}.tar.gz
TERMUX_PKG_SHA256=435850d3a12bc78baefd9e89bb6d7201a4a4ef493ad78bc14ac5a5332185da40
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	termux_setup_rust

	find . -type f -print0 | \
		xargs -0 sed -i \
		-e 's|"android"|"disabling_this_because_it_is_for_building_an_apk"|g' \
		-e 's|"linux"|"android"|g'
}

termux_step_make() {
	cargo build \
		--jobs "$TERMUX_PKG_MAKE_PROCESSES" \
		--target "$CARGO_TARGET_NAME" \
		--release \
		--all-features
}

termux_step_make_install() {
	install -Dm755 -t "$TERMUX_PREFIX/bin" "target/${CARGO_TARGET_NAME}/release/playitd"
	install -Dm755 -t "$TERMUX_PREFIX/bin" "target/${CARGO_TARGET_NAME}/release/playitd-service"
	install -Dm755 -t "$TERMUX_PREFIX/bin" "target/${CARGO_TARGET_NAME}/release/playitd-tray"
	install -Dm755 -t "$TERMUX_PREFIX/bin" "target/${CARGO_TARGET_NAME}/release/playit-cli"
}

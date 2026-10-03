TERMUX_PKG_HOMEPAGE=https://github.com/tbillington/kondo
TERMUX_PKG_DESCRIPTION="Cleans node_modules, target, build, and friends from your projects"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="Gouranga Das Samrat <gouranga.das.khulna@gmail.com>"
TERMUX_PKG_VERSION="0.9"
TERMUX_PKG_SRCURL="https://github.com/tbillington/kondo/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=188c577f1d21d783cd2b4b43a5cbae5ffe8b085e5773e10846af55968ddd50c4
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_make() {
	termux_setup_rust

	# Only the CLI; kondo-ui is a separate GUI (bevy) and not part of the workspace.
	cargo build \
		--jobs "${TERMUX_PKG_MAKE_PROCESSES}" \
		--target "${CARGO_TARGET_NAME}" \
		--release \
		--package kondo
}

termux_step_make_install() {
	install -Dm700 -t "${TERMUX_PREFIX}/bin" \
		"target/${CARGO_TARGET_NAME}/release/${TERMUX_PKG_NAME}"

	# Shell completions
	mkdir -p "${TERMUX_PREFIX}/share/zsh/site-functions"
	mkdir -p "${TERMUX_PREFIX}/share/bash-completion/completions"
	mkdir -p "${TERMUX_PREFIX}/share/fish/vendor_completions.d"
	mkdir -p "${TERMUX_PREFIX}/share/elvish/lib"
	(
		unset CC CXX CFLAGS CXXFLAGS CPPFLAGS LDFLAGS AR AS CPP LD RANLIB READELF STRIP
		cargo run --package kondo -- --completions zsh > "${TERMUX_PREFIX}/share/zsh/site-functions/_${TERMUX_PKG_NAME}"
		cargo run --package kondo -- --completions bash > "${TERMUX_PREFIX}/share/bash-completion/completions/${TERMUX_PKG_NAME}"
		cargo run --package kondo -- --completions fish > "${TERMUX_PREFIX}/share/fish/vendor_completions.d/${TERMUX_PKG_NAME}.fish"
		cargo run --package kondo -- --completions elvish > "${TERMUX_PREFIX}/share/elvish/lib/${TERMUX_PKG_NAME}.elv"
	)
}

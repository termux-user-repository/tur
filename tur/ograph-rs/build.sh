TERMUX_PKG_HOMEPAGE="https://git.average.name/AverageHelper/ograph-rs"
TERMUX_PKG_DESCRIPTION="A simple command-line utility to extract and print OpenGraph metadata from a given URL."
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@AverageHelper"
TERMUX_PKG_VERSION="0.4.1"
TERMUX_PKG_SRCURL="https://git.average.name/AverageHelper/ograph-rs/archive/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=ad0aec15a169709e584dcc1f4fe729bbc514e9ee86903b5b0ece40e1b48bed95
TERMUX_PKG_DEPENDS="openssl"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_pre_configure() {
	termux_setup_rust
}

termux_step_make() {
	cargo build --jobs $TERMUX_PKG_MAKE_PROCESSES --target $CARGO_TARGET_NAME --release --locked
}

termux_step_make_install() {
	# Move binary into place
	install -Dm700 -t $TERMUX_PREFIX/bin target/${CARGO_TARGET_NAME}/release/ograph

	# Move docs into place
	install -Dm600 -t $TERMUX_PREFIX/share/doc/$TERMUX_PKG_NAME README.*
}

termux_pkg_auto_update() {
	# Ask Forgejo for latest release
	local curl_response=$(
		curl \
			--silent \
			"https://git.average.name/api/v1/repos/AverageHelper/ograph-rs/releases/latest" \
			--write-out '|%{http_code}'
	) || {
		local http_code="${curl_response##*|}"
		if [[ "${http_code}" != "200" ]]; then
			echo "Error: failed to get latest ograph-rs release from ${TERMUX_PKG_HOMEPAGE}"
			exit 1
		fi
	}

	# Get version string in the following format: "v0.3.2"
	local remote_tag_name=$(echo $curl_response | cut -d"|" -f1 | jq .tag_name)

	# Strip the quotes and leading 'v'
	local latest_version=${remote_tag_name:2:-1}

	# Run upgrade if not latest
	termux_pkg_upgrade_version "${latest_version}"
}

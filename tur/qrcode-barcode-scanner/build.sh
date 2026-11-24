TERMUX_PKG_HOMEPAGE=https://github.com/qrcode-ai-com/qrcode-barcode-scanner-rust
TERMUX_PKG_DESCRIPTION="Offline QR code and barcode scanner for the command line (qrscan)"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_LICENSE_FILE="LICENSE, LICENSING.md, crates/qrcode-ai-scanner/LICENSE-APACHE-2.0, crates/qrcode-ai-scanner/THIRD-PARTY.md"
TERMUX_PKG_MAINTAINER="@ThibautMelen"
TERMUX_PKG_VERSION="0.12.0"
TERMUX_PKG_SRCURL="https://github.com/qrcode-ai-com/qrcode-barcode-scanner-rust/releases/download/v${TERMUX_PKG_VERSION}/qrcode-barcode-scanner-cli-${TERMUX_PKG_VERSION}-source.tar.gz"
TERMUX_PKG_SHA256=642f1cd4abcf16c2100eb8fdc2a84691a2af3d78549af4efce7398c2c6a78e17
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

# The repository also tags its other releases (swift-v*, oci-v*, mcpb-v*, linux-packages-v* and
# more), so its latest release or tag is not always qrscan. A qrscan version is a plain vX.Y.Z
# tag whose release carries the CLI source archive.
termux_pkg_auto_update() {
	local api="https://api.github.com/repos/qrcode-ai-com/qrcode-barcode-scanner-rust"
	local -a curl_opts=(-fsSL -H "Accept: application/vnd.github+json")
	if [[ -n "${GITHUB_TOKEN:-}" ]]; then
		curl_opts+=(-H "Authorization: token ${GITHUB_TOKEN}")
	fi

	local latest_version
	latest_version="$(
		curl "${curl_opts[@]}" "${api}/git/matching-refs/tags/v" | jq -r '.[].ref' |
			sed 's|^refs/tags/||' | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | sed 's/^v//' |
			sort -V | tail -n1
	)" || latest_version=""
	if [[ -z "${latest_version}" ]]; then
		echo "WARN: Unable to get the vX.Y.Z tags from upstream. Try again later." >&2
		return
	fi

	local source_archive="qrcode-barcode-scanner-cli-${latest_version}-source.tar.gz"
	local has_source
	has_source="$(
		curl "${curl_opts[@]}" "${api}/releases/tags/v${latest_version}" |
			jq -r --arg name "${source_archive}" 'any(.assets[]?; .name == $name)'
	)" || has_source=false
	if [[ "${has_source}" != true ]]; then
		echo "WARN: Release v${latest_version} has no ${source_archive} yet. Try again later." >&2
		return
	fi

	termux_pkg_upgrade_version "${latest_version}"
}

# The archive holds the whole workspace and its Cargo.lock; only the qrscan crate is built. Keep
# the workspace release profile (overflow checks in the rxing reader) and never set
# CARGO_PROFILE_RELEASE_PANIC=abort: the engine catches reader panics.

termux_step_pre_configure() {
	termux_setup_rust
}

termux_step_make() {
	cargo build \
		--jobs "$TERMUX_PKG_MAKE_PROCESSES" \
		--target "$CARGO_TARGET_NAME" \
		--release \
		--locked \
		-p qrcode-barcode-scanner-cli
}

termux_step_make_install() {
	install -Dm755 \
		"target/${CARGO_TARGET_NAME}/release/qrscan" \
		"${TERMUX_PREFIX}/bin/qrscan"
}

TERMUX_PKG_HOMEPAGE=https://github.com/qrcode-ai-com/qrcode-barcode-scanner-rust
TERMUX_PKG_DESCRIPTION="Offline QR code and barcode scanner for the command line (qrscan)"
TERMUX_PKG_LICENSE="AGPL-3.0-or-later"
TERMUX_PKG_LICENSE_FILE="LICENSE, LICENSING.md, crates/qrcode-ai-scanner/LICENSE-APACHE-2.0, crates/qrcode-ai-scanner/THIRD-PARTY.md"
TERMUX_PKG_MAINTAINER="@ThibautMelen"
TERMUX_PKG_VERSION="0.11.0"
TERMUX_PKG_SRCURL="https://github.com/qrcode-ai-com/qrcode-barcode-scanner-rust/releases/download/v${TERMUX_PKG_VERSION}/qrcode-barcode-scanner-cli-${TERMUX_PKG_VERSION}-source.tar.gz"
TERMUX_PKG_SHA256=8e5e09f0ec8d93ae49ca35615c05bb1d326448b6de9757cef86ef48d7bf3a96d
TERMUX_PKG_BUILD_IN_SRC=true
# The repository also publishes container and MCP releases, so its latest release is not always
# the CLI: a version bump stays a reviewed edit.
TERMUX_PKG_AUTO_UPDATE=false

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

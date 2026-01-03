TERMUX_PKG_HOMEPAGE=https://github.com/Linus-Mussmaecher/rucola
TERMUX_PKG_DESCRIPTION="Terminal-based markdown note manager"
TERMUX_PKG_LICENSE="GPL-3.0-only"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="0.8.2"
TERMUX_PKG_SRCURL="https://github.com/Linus-Mussmaecher/rucola/releases/download/v$TERMUX_PKG_VERSION/source.tar.gz"
TERMUX_PKG_SHA256=90e782c3ff0f3b66fe182841b2488b848e306f503a581d06c6ce05f634763e3e
TERMUX_PKG_DEPENDS="openssl"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_pre_configure() {
	termux_setup_rust

	cargo vendor
	find ./vendor \
		-mindepth 1 -maxdepth 1 -type d \
		! -wholename ./vendor/pwd \
		-exec rm -rf '{}' \;

	local patch dir="vendor/pwd"
	for patch in pwd-no-setpwent.diff pwd-no-gecos-32-bit.diff; do
		echo "Applying patch: $patch"
		patch -p1 -d "$dir" < "$TERMUX_PKG_BUILDER_DIR/$patch"
	done

	echo "" >> Cargo.toml
	echo '[patch.crates-io]' >> Cargo.toml
	echo 'pwd = { path = "./vendor/pwd" }' >> Cargo.toml
}

termux_step_make() {
	cargo build --jobs "$TERMUX_PKG_MAKE_PROCESSES" --target "$CARGO_TARGET_NAME" --release
}

termux_step_make_install() {
	install -Dm755 -t "$TERMUX_PREFIX/bin" "target/$CARGO_TARGET_NAME/release/$TERMUX_PKG_NAME"
	install -Dm644 -t "$TERMUX_PREFIX/share/doc/$TERMUX_PKG_NAME" README.md
	install -Dm644 -t "$TERMUX_PREFIX/share/doc/$TERMUX_PKG_NAME/default-config" default-config/*.{css,toml}
}

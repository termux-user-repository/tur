TERMUX_PKG_HOMEPAGE=https://iamb.chat/
TERMUX_PKG_DESCRIPTION="A terminal-based client for Matrix for the Vim addict"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="0.0.12"
TERMUX_PKG_SRCURL="https://github.com/ulyssa/iamb/archive/refs/tags/v$TERMUX_PKG_VERSION.tar.gz"
TERMUX_PKG_SHA256=54e3e87eece1aff22e9d6bd6798492a1d23ea5e831e9d0889b51272c7d4f6cdb
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	termux_setup_rust

	if [ "$TERMUX_ARCH" = "x86_64" ]; then
		RUSTFLAGS+=" -C link-arg=$($CC -print-libgcc-file-name)"
	fi

	# https://github.com/termux-user-repository/tur/pull/591#discussion_r2701702095
	cargo vendor
	find ./vendor \
		-mindepth 1 -maxdepth 1 -type d \
		! -wholename ./vendor/arboard \
		! -wholename ./vendor/x11rb-protocol \
		-exec rm -rf '{}' \;

	find vendor/{arboard,x11rb-protocol} -type f -print0 | \
		xargs -0 sed -i \
		-e 's|android|disabling_this_because_it_is_for_building_an_apk|g' \
		-e "s|/tmp|$TERMUX_PREFIX/tmp|g"

	echo "" >> Cargo.toml
	echo '[patch.crates-io]' >> Cargo.toml
	echo "arboard = { path = \"./vendor/arboard\" }" >> Cargo.toml
	echo "x11rb-protocol = { path = \"./vendor/x11rb-protocol\" }" >> Cargo.toml
}

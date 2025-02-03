TERMUX_PKG_HOMEPAGE=https://github.com/biomejs/biome
TERMUX_PKG_DESCRIPTION="A toolchain for web projects with a formatter and linter, usable via CLI and LSP"
TERMUX_PKG_LICENSE="Apache-2.0,MIT"
TERMUX_PKG_MAINTAINER="@gebleksengek"
TERMUX_PKG_VERSION="1.9.4"
TERMUX_PKG_GIT_BRANCH="cli/v$TERMUX_PKG_VERSION"
TERMUX_PKG_SRCURL=git+https://github.com/biomejs/biome.git
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_BUILD_DEPENDS="zlib"

termux_step_pre_configure() {
	termux_setup_rust
}

termux_step_make() {
	RUSTFLAGS="-C strip=symbols -C codegen-units=1" BIOME_VERSION=$TERMUX_PKG_VERSION cargo build --jobs $TERMUX_PKG_MAKE_PROCESSES --target $CARGO_TARGET_NAME --release
}

termux_step_make_install() {
	install -Dm700 -t $TERMUX_PREFIX/bin target/${CARGO_TARGET_NAME}/release/biome
}

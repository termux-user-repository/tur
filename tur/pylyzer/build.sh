TERMUX_PKG_HOMEPAGE=https://github.com/mtshiba/pylyzer.git
TERMUX_PKG_DESCRIPTION="A fast, feature-rich static code analyzer & language server for Python"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@AhmadNaruto"
TERMUX_PKG_VERSION="0.0.82"
TERMUX_PKG_GIT_BRANCH="v$TERMUX_PKG_VERSION"
TERMUX_PKG_SRCURL=git+https://github.com/mtshiba/pylyzer.git
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_pre_configure() {
	termux_setup_rust
}

termux_step_make() {
	RUSTFLAGS="-C strip=symbols -C codegen-units=1" cargo build --jobs $TERMUX_PKG_MAKE_PROCESSES --target $CARGO_TARGET_NAME --release  --locked
}

termux_step_make_install() {
	install -Dm700 -t $TERMUX_PREFIX/bin target/${CARGO_TARGET_NAME}/release/pylyzer
}

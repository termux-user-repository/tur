TERMUX_PKG_HOMEPAGE=https://github.com/Cretezy/lazyjj
TERMUX_PKG_DESCRIPTION="TUI for Jujutsu/jj"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@AhmadNaruto"
TERMUX_PKG_VERSION="0.6.1"
TERMUX_PKG_GIT_BRANCH="v$TERMUX_PKG_VERSION"
TERMUX_PKG_SRCURL=git+https://github.com/Cretezy/lazyjj
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_DEPENDS="jujutsu"
#TERMUX_PKG_BUILD_DEPENDS="zlib"

termux_step_pre_configure() {
	termux_setup_rust
}

termux_step_make() {
	cargo build --jobs "$TERMUX_PKG_MAKE_PROCESSES" --target "$CARGO_TARGET_NAME" --release --locked
}

termux_step_make_install() {
	install -Dm700 -t "$TERMUX_PREFIX/bin" "target/${CARGO_TARGET_NAME}/release/lazyjj"
}

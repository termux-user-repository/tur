TERMUX_PKG_HOMEPAGE=https://topiary.tweag.io/
TERMUX_PKG_DESCRIPTION="The universal code formatter"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="0.7.0"
TERMUX_PKG_SRCURL=https://github.com/tweag/topiary/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=88f90418b9a87f8b80d914f8cae00b173b5db9961ac9bcda4c063d6ed4b76aa8
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_TAG_TYPE=latest-release-tag

termux_step_pre_configure() {
	# clash with rust host build
	# causes 32bit builds to fail if set
	unset CFLAGS
	termux_setup_rust
}

termux_step_make() {
	cargo build --jobs $TERMUX_PKG_MAKE_PROCESSES --target $CARGO_TARGET_NAME --release
}

termux_step_make_install() {
	install -Dm755 -t $TERMUX_PREFIX/bin target/${CARGO_TARGET_NAME}/release/topiary

	# Shell Completions
	cargo run --bin topiary -- completion    zsh \
		| install -Dm644 /dev/stdin "$TERMUX_PREFIX/share/zsh/site-functions/_${TERMUX_PKG_NAME}"
	cargo run --bin topiary -- completion   bash \
		| install -Dm644 /dev/stdin "$TERMUX_PREFIX/share/bash-completion/completions/${TERMUX_PKG_NAME}.bash"
	cargo run --bin topiary -- completion   fish \
		| install -Dm644 /dev/stdin "$TERMUX_PREFIX/share/fish/vendor_completions.d/${TERMUX_PKG_NAME}.fish"
	cargo run --bin topiary -- completion elvish \
		| install -Dm644 /dev/stdin "$TERMUX_PREFIX/share/elvish/lib/${TERMUX_PKG_NAME}.elv"
	}

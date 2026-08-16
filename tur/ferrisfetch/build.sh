TERMUX_PKG_HOMEPAGE=https://github.com/Kk376/ferrisfetch
TERMUX_PKG_DESCRIPTION="A fast, lightweight Linux and Android system information fetch CLI written in Rust"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="Kushagra Kumar <kk376@users.noreply.github.com>"
TERMUX_PKG_VERSION="0.1.0"
TERMUX_PKG_SRCURL="https://github.com/Kk376/ferrisfetch/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=6e2fbf052988cb945c436087f42dcf9ebd8885d3cd19638b58221e7d41eca9df
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_make() {
	termux_setup_rust
	cargo build --jobs $TERMUX_PKG_MAKE_PROCESSES --target $CARGO_TARGET_NAME --release
}

termux_step_make_install() {
	install -Dm755 target/${CARGO_TARGET_NAME}/release/ferrisfetch $TERMUX_PREFIX/bin/ferrisfetch
	install -Dm644 completions/ferrisfetch.bash $TERMUX_PREFIX/share/bash-completion/completions/ferrisfetch
	install -Dm644 completions/_ferrisfetch $TERMUX_PREFIX/share/zsh/site-functions/_ferrisfetch
	install -Dm644 completions/ferrisfetch.fish $TERMUX_PREFIX/share/fish/vendor_completions.d/ferrisfetch.fish
}

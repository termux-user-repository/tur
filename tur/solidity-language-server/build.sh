TERMUX_PKG_HOMEPAGE=https://github.com/asyncswap/solidity-language-server
TERMUX_PKG_DESCRIPTION="A fast Solidity language server powered by solc and foundry, written in Rust."
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="0.1.35"
TERMUX_PKG_SRCURL="https://github.com/asyncswap/solidity-language-server/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=6fa2db82a680818ff9003f78c801ffb7a3d9d625b0cc68194ead738473e97c2d
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_DEPENDS="solidity"
TERMUX_PKG_BUILD_IN_SRC=true


termux_step_pre_configure() {
	termux_setup_rust
}

termux_step_make() {
	cargo build \
		--bin solidity-language-server \
		--jobs "${TERMUX_PKG_MAKE_PROCESSES}" \
		--target "${CARGO_TARGET_NAME}" \
		--release
}

termux_step_make_install() {
	install -Dm755 \
		target/"${CARGO_TARGET_NAME}"/release/solidity-language-server \
		"$TERMUX_PREFIX"/bin/solidity-language-server
}

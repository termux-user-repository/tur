TERMUX_PKG_HOMEPAGE=https://github.com/asyncswap/solidity-language-server
TERMUX_PKG_DESCRIPTION="A fast Solidity language server powered by solc and foundry, written in Rust."
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="0.1.38"
TERMUX_PKG_SRCURL="https://github.com/asyncswap/solidity-language-server/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=b1dd22f123b51d7266c9a95cee22c5fc7bfb6cc2b2b70eaf193a62fc44ca4680
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

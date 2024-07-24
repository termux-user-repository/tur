TERMUX_PKG_HOMEPAGE="https://git.sr.ht/~bitfehler/vomit"
TERMUX_PKG_DESCRIPTION="Utility to manage your local emails in Maildir++ format with IMAP synchronization support"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@flosnvjx"
TERMUX_PKG_VERSION="0.4.0"
TERMUX_PKG_DEPENDS="openssl"
TERMUX_PKG_SRCURL="https://git.sr.ht/~bitfehler/vomit/archive/v$TERMUX_PKG_VERSION.tar.gz"
TERMUX_PKG_SHA256=8f89f99e868e18d667fbe8be04b4badb3878dec362105151f48125c82732cff1
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_METHOD=repology
TERMUX_PKG_UPDATE_VERSION_REGEXP="^0\.[0-9]+(\.[0-9]+)*$" ## 0.xx

termux_step_make() {
	termux_setup_rust
	cargo build --jobs $TERMUX_PKG_MAKE_PROCESSES --target $CARGO_TARGET_NAME --release --locked

	printf '%s\n' "Generate document file of vomit-config..." >&2
	local vomitConfigVer="$(sed -nEe '/^vomit-config = "([0-9.]+)"$/ s%.* = "([0-9.]+)"%\1%p' Cargo.toml | head -n 1)"
	curl -qgfLo vomit-config.txt "https://git.sr.ht/~bitfehler/vomit-config/blob/v$vomitConfigVer/src/lib.rs"
	sed -nEe '/^\/\/\!/s%//\!%%p' -i vomit-config.txt
}

termux_step_make_install() {
	install -vDm700 -t $TERMUX_PREFIX/bin target/${CARGO_TARGET_NAME}/release/vmt
	mkdir -vp $TERMUX_PREFIX/share/{doc/vomit,bash-completion/completions}
	cp -t $TERMUX_PREFIX/share/doc/vomit README.md vomit-config.txt
	cp contrib/vmt-completion.bash $TERMUX_PREFIX/share/bash-completion/completions/vmt
}

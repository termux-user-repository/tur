TERMUX_PKG_HOMEPAGE=https://github.com/casey/intermodal
TERMUX_PKG_DESCRIPTION="A command-line utility for BitTorrent torrent file creation, verification, and more"
TERMUX_PKG_LICENSE="CC0-1.0"
TERMUX_PKG_MAINTAINER="@flosnvjx"
TERMUX_PKG_VERSION=0.1.14
TERMUX_PKG_SRCURL="https://github.com/casey/intermodal/archive/refs/tags/v$TERMUX_PKG_VERSION.tar.gz"
TERMUX_PKG_SHA256=4b42fc39246a637e8011a520639019d33beffb337ed4e45110260eb67ecec9cb
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_make() {
	termux_setup_rust
	cargo build --jobs $TERMUX_PKG_MAKE_PROCESSES --target $CARGO_TARGET_NAME --release --locked
}

termux_step_make_install() {
	install -Dm755 -t $TERMUX_PREFIX/bin target/${CARGO_TARGET_NAME}/release/imdl
	install -Dm644 -t $TERMUX_PREFIX/share/doc/$TERMUX_PKG_NAME README*
}

termux_step_post_make_install() {
	# Make a placeholder for shell-completions (to be filled with postinst)
	mkdir -p "${TERMUX_PREFIX}"/share/bash-completion/completions
	mkdir -p "${TERMUX_PREFIX}"/share/elvish/lib
	mkdir -p "${TERMUX_PREFIX}"/share/fish/vendor_completions.d
	mkdir -p "${TERMUX_PREFIX}"/share/nushell/vendor/autoload
	mkdir -p "${TERMUX_PREFIX}"/share/zsh/site-functions
	touch "${TERMUX_PREFIX}"/share/bash-completion/completions/imdl
	touch "${TERMUX_PREFIX}"/share/elvish/lib/imdl.elv
	touch "${TERMUX_PREFIX}"/share/fish/vendor_completions.d/imdl.fish
	touch "${TERMUX_PREFIX}"/share/zsh/site-functions/_imdl
}

termux_step_create_debscripts() {
	cat <<-EOF >./postinst
		#!${TERMUX_PREFIX}/bin/sh

		imdl completions -s bash > ${TERMUX_PREFIX}/share/bash-completion/completions/imdl
		imdl completions -s elvish > ${TERMUX_PREFIX}/share/elvish/lib/imdl.elv
		imdl completions -s fish > ${TERMUX_PREFIX}/share/fish/vendor_completions.d/imdl.fish
		imdl completions -s zsh > ${TERMUX_PREFIX}/share/zsh/site-functions/_imdl
	EOF
	if [ "$TERMUX_PACKAGE_FORMAT" = "pacman" ]; then
		echo "post_install" > postupg
	fi
}

TERMUX_PKG_HOMEPAGE=https://github.com/cassava/repoctl
TERMUX_PKG_DESCRIPTION="libalpm(3) repository supplement utility"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@flosnvjx"
TERMUX_PKG_VERSION=0.21
TERMUX_PKG_SRCURL="https://github.com/cassava/repoctl/releases/download/v$TERMUX_PKG_VERSION/repoctl-$TERMUX_PKG_VERSION.tar.gz"
TERMUX_PKG_SHA256=b6abb00c57475c6bbef48d1a6831fa30e82950fe1f5a599cc7aff6d6f86435e9
TERMUX_PKG_DEPENDS="pacman"
TERMUX_PKG_BUILD_IN_SRC=true
#TERMUX_PKG_AUTO_UPDATE=true

termux_step_make() {
	termux_setup_golang
	mkdir bin
	go build -o ./bin -trimpath
}

termux_step_make_install() {
	install -Dm700 -t $TERMUX_PREFIX/bin bin/*

	install -dm700 $TERMUX_PREFIX/share/{zsh/site-functions/,bash-completion/completions,fish/vendor_completions.d}
	## placehold
	touch -- $TERMUX_PREFIX/share/{zsh/site-functions/_repoctl,bash-completion/completions/repoctl,fish/vendor_completions.d/repoctl.fish}

	install -Dm600 -t $TERMUX_PREFIX/share/doc/$TERMUX_PKG_NAME README.* NEWS.*
}

termux_step_create_debscripts() {
	cat <<- EOF > ./postinst
	#!/bin/sh
	$PREFIX/bin/repoctl completion bash > $PREFIX/share/zsh/site-functions/_repoctl
	$PREFIX/bin/repoctl completion zsh > $PREFIX/share/bash-completion/completions/repoctl
	$PREFIX/bin/repoctl completion fish > $PREFIX/share/fish/vendor_completions.d/repoctl.fish
	EOF
}

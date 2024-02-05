TERMUX_PKG_HOMEPAGE=https://github.com/stern/stern
TERMUX_PKG_DESCRIPTION="⎈ Multi pod and container log tailing for Kubernetes -- Friendly fork of https://github.com/wercker/stern"
TERMUX_PKG_LICENSE="Apache License 2.0"
TERMUX_PKG_LICENSE_FILE="LICENSE"
TERMUX_PKG_MAINTAINER="@idj0"
TERMUX_PKG_VERSION=1.28.0
TERMUX_PKG_SRCURL=https://github.com/stern/stern/archive/refs/tags/v$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=7d0914cc3a3b884cce5bcbeb439f5c651c72f0737ba9517b663d7f911804489e
TERMUX_PKG_DEPENDS="pacman, kubectl"
TERMUX_PKG_BUILD_DEPENDS="golang"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_TAG_TYPE="newest-tag"

termux_step_make() {
	termux_setup_golang

	mkdir bin
	go build -o ./bin ./...

	mkdir -p completions/zsh
	./bin/stern --completion zsh >completions/zsh/_stern

	mkdir -p completions/bash
	./bin/stern --completion bash >completions/bash/stern

	mkdir -p completions/fish
	./bin/stern --completion fish >completions/fish/stern.fish
}

termux_step_make_install() {
	install -Dm700 -t $TERMUX_PREFIX/bin bin/stern

	install -Dm600 completions/zsh/_stern \
		-t $TERMUX_PREFIX/share/zsh/site-functions
	install -Dm600 completions/bash/stern \
		-t $TERMUX_PREFIX/share/bash-completion/completions
	install -Dm600 completions/fish/stern.fish \
		-t "$TERMUX_PREFIX"/share/fish/completions
}

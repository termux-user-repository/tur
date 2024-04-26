TERMUX_PKG_HOMEPAGE=https://github.com/stern/stern
TERMUX_PKG_DESCRIPTION="Multi pod and container log tailing for Kubernetes - Fork of https://github.com/wercker/stern"
TERMUX_PKG_LICENSE="Apache-2.0"
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
}

termux_step_make_install() {
	install -Dm700 -t $TERMUX_PREFIX/bin bin/stern
}

termux_step_post_make_install() {
	mkdir -p ${TERMUX_PREFIX}/share/zsh/site-functions
	mkdir -p ${TERMUX_PREFIX}/share/bash-completions/completions
	mkdir -p ${TERMUX_PREFIX}/share/fish/vendor_completions.d

	touch ${TERMUX_PREFIX}/share/zsh/site-functions/_stern
	touch ${TERMUX_PREFIX}/share/bash-completions/completions/stern
	touch ${TERMUX_PREFIX}/share/fish/vendor_completions.d/stern.fish
}

termux_step_create_debscripts() {
	cat <<- EOF > ./postinst
		#!${TERMUX_PREFIX}/bin/sh

		stern --completion zsh  > ${TERMUX_PREFIX}/share/zsh/site-functions/_stern
		stern --completion bash > ${TERMUX_PREFIX}/share/bash-completions/completions/stern
		stern --completion fish > ${TERMUX_PREFIX}/share/fish/vendor_completions.d/stern.fish
	EOF
}

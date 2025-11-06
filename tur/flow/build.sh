TERMUX_PKG_HOMEPAGE=https://github.com/flowexec/flow
TERMUX_PKG_DESCRIPTION="Local developer automation platform that flows with you."
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="1.1.2"
TERMUX_PKG_SRCURL=https://github.com/flowexec/flow/archive/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=b86762a08b913cd295a9f5616ca140cd8e4732c14395c2316a07105da167ccf0
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_TAG_TYPE="latest-release-tag"

termux_step_pre_configure() {
	termux_setup_golang
}

termux_step_make() {
	export GOEXPERIMENT='greenteagc'
	read commit_hash commit_date < <(
		curl -s "https://api.github.com/repos/flowexec/flow/commits/v${TERMUX_PKG_VERSION}" \
			| jq -r '.sha, .commit.committer.date'
	)
	local _ldflags="-s -w -X github.com/flowexec/flow/cmd/internal/version.version=${TERMUX_PKG_VERSION}"
	_ldflags+=" -X github.com/flowexec/flow/cmd/internal/version.gitCommit=${commit_hash}"
	_ldflags+=" -X github.com/flowexec/flow/cmd/internal/version.buildDate=$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
	go build --ldflags="$_ldflags"
}

termux_step_make_install() {
	mkdir -p "${TERMUX_PREFIX}/share/zsh/site-functions"
	mkdir -p "${TERMUX_PREFIX}/share/fish/vendor_completions.d"
	mkdir -p "${TERMUX_PREFIX}/share/bash-completion/completions"

	unset GOOS GOARCH CGO_LDFLAGS
	unset CC CXX CFLAGS CXXFLAGS LDFLAGS
	go run . completion  zsh > "${TERMUX_PREFIX}/share/zsh/site-functions/_${TERMUX_PKG_NAME}"
	go run . completion bash > "${TERMUX_PREFIX}/share/bash-completion/completions/${TERMUX_PKG_NAME}"
	go run . completion fish > "${TERMUX_PREFIX}/share/fish/vendor_completions.d/${TERMUX_PKG_NAME}.fish"
	install -Dm700 flow "$TERMUX_PREFIX/bin/flow"
}

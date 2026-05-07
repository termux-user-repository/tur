TERMUX_PKG_HOMEPAGE=https://github.com/charmbracelet/crush
TERMUX_PKG_DESCRIPTION="The glamourous AI coding agent for your favourite terminal"
TERMUX_PKG_LICENSE="custom"
TERMUX_PKG_LICENSE_FILE="LICENSE.md"
TERMUX_PKG_MAINTAINER="@ancientcatz"
TERMUX_PKG_VERSION="0.66.0"
TERMUX_PKG_SRCURL=https://github.com/charmbracelet/crush/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=87246691bfdc927003847bfe7f18ac70fe02110a40cb4e0c88ca14ec0aa61c3e
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=false
TERMUX_PKG_UPDATE_TAG_TYPE="latest-release-tag"

termux_step_pre_configure() {
	termux_setup_golang
}

termux_step_make() {
	read -r commit_hash commit_date commit_epoch < <(
		curl -s "https://api.github.com/repos/charmbracelet/crush/commits/v${TERMUX_PKG_VERSION}" \
			| jq -r '[.sha, .commit.committer.date, (.commit.committer.date | fromdateiso8601)] | @tsv'
	)
	go build -trimpath -buildvcs=false -ldflags "-s -w -X github.com/charmbracelet/crush/internal/version.Version=${TERMUX_PKG_VERSION} -buildid="
	touch -d "@${commit_epoch}" "crush"
}

termux_step_make_install() {
	mkdir -p "${TERMUX_PREFIX}/share/man/man1"
	mkdir -p "${TERMUX_PREFIX}/share/zsh/site-functions"
	mkdir -p "${TERMUX_PREFIX}/share/fish/vendor_completions.d"
	mkdir -p "${TERMUX_PREFIX}/share/bash-completion/completions"

	unset GOOS GOARCH CGO_LDFLAGS
	unset CC CXX CFLAGS CXXFLAGS LDFLAGS
	go run .             man > "${TERMUX_PREFIX}/share/man/man1/${TERMUX_PKG_NAME}.1"
	go run . completion  zsh > "${TERMUX_PREFIX}/share/zsh/site-functions/_${TERMUX_PKG_NAME}"
	go run . completion bash > "${TERMUX_PREFIX}/share/bash-completion/completions/${TERMUX_PKG_NAME}"
	go run . completion fish > "${TERMUX_PREFIX}/share/fish/vendor_completions.d/${TERMUX_PKG_NAME}.fish"
	install -Dm700 crush "$TERMUX_PREFIX/bin/crush"
}

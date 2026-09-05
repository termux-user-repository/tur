TERMUX_PKG_HOMEPAGE=https://github.com/tailscale/tailcat
TERMUX_PKG_DESCRIPTION="like netcat, but over Tailscale's data plane, without Tailscale's control plane"
TERMUX_PKG_LICENSE="BSD 3-Clause"
TERMUX_PKG_MAINTAINER="@ancientcatz"
TERMUX_PKG_VERSION="0.6.0"
TERMUX_PKG_SRCURL=https://github.com/tailscale/tailcat/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=14d0e1a80dd4836053dd3e2cd6bbb1ad40ecf72c181c3f92d319d325bf7f6e6f
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_TAG_TYPE="latest-release-tag"

termux_step_pre_configure() {
	termux_setup_golang
}

termux_step_make() {
	read -r commit_hash commit_date commit_epoch < <(
		curl -s "https://api.github.com/repos/tailscale/tailcat/commits/v${TERMUX_PKG_VERSION}" \
			| jq -r '[.sha, .commit.committer.date, (.commit.committer.date | fromdateiso8601)] | @tsv'
	)

	sed -i 's/\(netgo,\|osusergo,\)//g' build-tags.txt

	local build_tags="$(cat build-tags.txt)"

	go build \
		-ldflags "-s -w -X main.version=v${TERMUX_PKG_VERSION} -buildid=" \
		-tags="${build_tags}" \
		-trimpath \
		-buildvcs=false \
		./cmd/tailcat
	touch -d "@${commit_epoch}" "tailcat"
}

termux_step_make_install() {
	unset GOOS GOARCH CGO_LDFLAGS
	unset CC CXX CFLAGS CXXFLAGS LDFLAGS
	install -Dm700 tailcat "$TERMUX_PREFIX/bin/tailcat"
}

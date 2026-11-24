TERMUX_PKG_HOMEPAGE=https://github.com/tailscale/tailcat
TERMUX_PKG_DESCRIPTION="like netcat, but over Tailscale's data plane, without Tailscale's control plane"
TERMUX_PKG_LICENSE="BSD 3-Clause"
TERMUX_PKG_MAINTAINER="@ancientcatz"
TERMUX_PKG_VERSION="0.8.0"
TERMUX_PKG_SRCURL=https://github.com/tailscale/tailcat/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=4bcf86535445f1160f29958dbce57fda54bb203ffb89e5a153b6ecc933e91814
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_TAG_TYPE="latest-release-tag"

termux_step_pre_configure() {
	termux_setup_golang
}

termux_step_make() {
	sed -i 's/\(netgo,\|osusergo,\)//g' build-tags.txt
	local build_tags="$(cat build-tags.txt)"
	go build \
		-ldflags "-s -w -X main.version=v${TERMUX_PKG_VERSION} -buildid=" \
		-tags="${build_tags}" \
		-trimpath \
		-buildvcs=false \
		./cmd/tailcat
}

termux_step_make_install() {
	unset GOOS GOARCH CGO_LDFLAGS
	unset CC CXX CFLAGS CXXFLAGS LDFLAGS
	install -Dm700 tailcat "$TERMUX_PREFIX/bin/tailcat"
}

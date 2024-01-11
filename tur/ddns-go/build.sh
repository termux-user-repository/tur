TERMUX_PKG_HOMEPAGE=https://github.com/jeessy2/ddns-go
TERMUX_PKG_DESCRIPTION="A simple, easy-to-use ddns service"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="6.0.0"
TERMUX_PKG_SRCURL=https://github.com/jeessy2/ddns-go/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=db7da87e1691f11ebc5b49dffb1e7ab3df243d3713e7e139372de30dcf6de15f
TERMUX_PKG_DEPENDS="libc++"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	termux_setup_golang
}

termux_step_make() {
	local _buildtime=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

	go build -ldflags="-X main.version=$TERMUX_PKG_VERSION -X main.buildTime=$_buildtime -extldflags -s -w" \
		-trimpath -buildmode=pie -o ddns-go .
}

termux_step_make_install() {
	install -Dm700 -t "${TERMUX_PREFIX}"/bin "$TERMUX_PKG_SRCDIR"/ddns-go
}

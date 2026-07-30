TERMUX_PKG_HOMEPAGE=https://github.com/jeessy2/ddns-go
TERMUX_PKG_DESCRIPTION="A simple, easy-to-use ddns service"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="6.17.4"
TERMUX_PKG_SRCURL=https://github.com/jeessy2/ddns-go/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=80f3816d95933949ce7306b988b2612d91b95c6992af8e956378628fde19b615
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

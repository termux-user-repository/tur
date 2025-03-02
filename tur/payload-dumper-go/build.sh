TERMUX_PKG_HOMEPAGE="https://github.com/ssut/payload-dumper-go"
TERMUX_PKG_DESCRIPTION="An android OTA payload dumper written in Go"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_VERSION="1.3.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_SRCURL=https://github.com/ssut/payload-dumper-go/archive/refs/tags/${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=d7ba33a80c539674c0b63443b8c6dd9c2040ec996323f38ffe72e024d302eb2d
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_BUILD_DEPENDS="xz-utils"
TERMUX_PKG_DEPENDS="xz-utils"

termux_step_make() {
	termux_setup_golang
	go build -o payload-dumper-go
}

termux_step_make_install() {
	install -Dm700 -t "${TERMUX_PREFIX}"/bin payload-dumper-go
}

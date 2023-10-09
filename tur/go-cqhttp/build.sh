TERMUX_PKG_HOMEPAGE=https://docs.go-cqhttp.org
TERMUX_PKG_DESCRIPTION="The golang implementation of cqhttp, lightweight, native cross-platform"
TERMUX_PKG_LICENSE="AGPL-V3"
TERMUX_PKG_MAINTAINER="2096779623 <admin@utermux.dev>"
TERMUX_PKG_VERSION="1.2.0"
TERMUX_PKG_SRCURL=https://github.com/Mrs4s/go-cqhttp/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=2abf0b93c9fdf42a009134c8f8d1637c351a5c985e37432a733c847a834d630b
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	termux_setup_golang

	go mod init || :
	go mod tidy
}

termux_step_make() {
	go build -o go-cqhttp -ldflags="-w -s -X 'github.com/Mrs4s/go-cqhttp/internal/base.Version=${TERMUX_PKG_VERSION}'"
}

termux_step_make_install() {
	install -Dm700 -t "${TERMUX_PREFIX}"/bin "$TERMUX_PKG_SRCDIR"/go-cqhttp
}

TERMUX_PKG_HOMEPAGE=https://github.com/jpillora/chisel
TERMUX_PKG_DESCRIPTION="A fast TCP/UDP tunnel over HTTP, secured via SSH"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@ih532268-cell <283420161+ih532268-cell@users.noreply.github.com>"
TERMUX_PKG_VERSION="1.12.0"
TERMUX_PKG_SRCURL="https://github.com/jpillora/chisel/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=5c25f054b64814f770725593db525faa1999960aecf4eb15c86529dea573c431
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_make() {
	termux_setup_golang

	go build -v \
		-ldflags "-s -w -X github.com/jpillora/chisel/share.BuildVersion=${TERMUX_PKG_VERSION}" \
		-o chisel .
}

termux_step_make_install() {
	install -Dm755 -t "${TERMUX_PREFIX}"/bin chisel
}

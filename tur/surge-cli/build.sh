TERMUX_PKG_HOMEPAGE=https://github.com/SurgeDM/Surge
TERMUX_PKG_DESCRIPTION="Blazing fast TUI download manager built in Go for power users"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@LukeGTH"
TERMUX_PKG_VERSION="0.11.2"
TERMUX_PKG_SRCURL="https://github.com/SurgeDM/Surge/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=a8c9cb5c8af161959a89bbbae551a9fe28180d6c5e5315d03a1b7b5cc730d102
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_DEPENDS="file"
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_post_get_source() {
	termux_setup_golang
	go mod vendor
}

termux_step_make() {
	termux_setup_golang
	go build -o surge
}

termux_step_make_install() {
	install -Dm755 "$TERMUX_PKG_SRCDIR/surge" "${TERMUX_PREFIX}/bin/surge"
}

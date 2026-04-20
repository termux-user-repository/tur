TERMUX_PKG_HOMEPAGE=https://github.com/SurgeDM/Surge
TERMUX_PKG_DESCRIPTION="Blazing fast TUI download manager built in Go for power users"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@LukeGTH"
TERMUX_PKG_VERSION="0.8.2"
TERMUX_PKG_SRCURL="https://github.com/SurgeDM/Surge/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=ac495c5420a4a092cf408cb0e228cdf9406fa933e437ceb5c279d4ea22e38376
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

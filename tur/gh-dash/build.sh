TERMUX_PKG_HOMEPAGE=https://github.com/dlvhdr/gh-dash
TERMUX_PKG_DESCRIPTION="A rich terminal UI for GitHub that doesn't break your flow"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@everywhereless"
TERMUX_PKG_VERSION="4.24.1"
TERMUX_PKG_SRCURL="https://github.com/dlvhdr/gh-dash/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=928f39ef26711d49d81e827e9759482add511c5fe792c788214db2fdb09bbe34
TERMUX_PKG_DEPENDS="gh"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	termux_setup_golang
}

termux_step_make() {
	go build \
		-v \
		-o gh-dash \
		.
}

termux_step_make_install() {
	install -Dm755 gh-dash \
		"${TERMUX_PREFIX}/bin/gh-dash"
}

TERMUX_PKG_HOMEPAGE=https://github.com/dlvhdr/gh-dash
TERMUX_PKG_DESCRIPTION="A rich terminal UI for GitHub that doesn't break your flow"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@everywhereless"
TERMUX_PKG_VERSION="4.26.2"
TERMUX_PKG_SRCURL="https://github.com/dlvhdr/gh-dash/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=65b46a8d5eeddf170aff6f30f601df641efd2291a0fcecaff07752f6d33d1ccd
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

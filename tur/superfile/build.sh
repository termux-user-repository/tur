TERMUX_PKG_HOMEPAGE=https://github.com/yorukot/superfile
TERMUX_PKG_DESCRIPTION="Pretty fancy and modern terminal file manager"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@everywhereless"
TERMUX_PKG_VERSION="1.5.0"
TERMUX_PKG_SRCURL="https://github.com/yorukot/superfile/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=bb394f73817d164b9756613ccd850fb3dd5fd5ee898defd86b27eecd4cec48bf
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_EXCLUDED_ARCHES="arm, i686"

termux_step_pre_configure() {
	termux_setup_golang
}

termux_step_make() {
	go build \
		-v \
		-o spf \
		.
}

termux_step_make_install() {
	install -Dm755 spf \
		"${TERMUX_PREFIX}/bin/spf"
}

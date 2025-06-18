TERMUX_PKG_HOMEPAGE="https://github.com/homeport/termshot"
TERMUX_PKG_DESCRIPTION="Creates screenshots based on terminal command output"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@Veha0001"
TERMUX_PKG_VERSION=0.5.0
TERMUX_PKG_SRCURL=git+https://github.com/homeport/termshot
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_DEPENDS="imagemagick"

termux_step_pre_configure() {
	termux_setup_golang
}

termux_step_make() {
	go build -ldflags="-X github.com/homeport/termshot/internal/cmd.version=$TERMUX_PKG_VERSION" -trimpath -o termshot ./cmd/termshot
}

termux_step_make_install() {
	install -Dm700 termshot "${TERMUX_PREFIX}/bin/termshot"
}

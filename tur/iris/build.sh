TERMUX_PKG_HOMEPAGE=https://github.com/versenilvis/IRIS
TERMUX_PKG_DESCRIPTION="A shell auto-completion tool for your terminal"
TERMUX_PKG_LICENSE="custom"
TERMUX_PKG_LICENSE_FILE="LICENSE"
TERMUX_PKG_MAINTAINER="@everywhereless"
TERMUX_PKG_VERSION="0.7.6"
TERMUX_PKG_SRCURL="https://github.com/versenilvis/IRIS/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=0d3ea32e94dd7253e5053579ced71ea046bf07179dd9c4179d9a0092e1abb3df
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	termux_setup_golang
}

termux_step_make() {
	go build -o iris ./cmd/iris
}

termux_step_make_install() {
	install -Dm755 iris \
		"${TERMUX_PREFIX}/bin/iris"
}

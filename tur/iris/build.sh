TERMUX_PKG_HOMEPAGE=https://github.com/versenilvis/IRIS
TERMUX_PKG_DESCRIPTION="A shell auto-completion tool for your terminal"
TERMUX_PKG_LICENSE="custom"
TERMUX_PKG_LICENSE_FILE="LICENSE"
TERMUX_PKG_MAINTAINER="@everywhereless"
TERMUX_PKG_VERSION="0.7.3"
TERMUX_PKG_SRCURL="https://github.com/versenilvis/IRIS/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=8e053c98a9315e73d5fe63c72456f1133775a0a81602e031e26fafa51f7d42e7
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

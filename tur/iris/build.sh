TERMUX_PKG_HOMEPAGE=https://github.com/versenilvis/IRIS
TERMUX_PKG_DESCRIPTION="A shell auto-completion tool for your terminal"
TERMUX_PKG_LICENSE="custom"
TERMUX_PKG_LICENSE_FILE="LICENSE"
TERMUX_PKG_MAINTAINER="@everywhereless"
TERMUX_PKG_VERSION="0.8.1"
TERMUX_PKG_SRCURL="https://github.com/versenilvis/IRIS/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=1c5e40b5078faa79768e5e5996f438c2ade9108d61717a5b7a76e675892cd638
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

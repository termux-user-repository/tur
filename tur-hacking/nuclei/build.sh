TERMUX_PKG_HOMEPAGE=https://github.com/projectdiscovery/nuclei
TERMUX_PKG_DESCRIPTION="Fast, customizable web vulnerability scanner tool"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@hasanzkan3"
TERMUX_PKG_VERSION="3.11.1"
TERMUX_PKG_SRCURL="https://github.com/projectdiscovery/nuclei/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256="64c6e21eb8cd141d39cbb0241228fb40fd4370dbe39dc9f13e1069c718b711f9"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_make() {
    termux_setup_golang
    
    cd "${TERMUX_PKG_SRCDIR}/cmd/nuclei"
    go build -v -ldflags="-s -w" -o "${TERMUX_PKG_BUILDDIR}/nuclei" .
}

termux_step_make_install() {
    install -Dm700 -t "${TERMUX_PREFIX}/bin" "${TERMUX_PKG_BUILDDIR}/nuclei"
}

TERMUX_PKG_HOMEPAGE=https://github.com/projectdiscovery/subfinder
TERMUX_PKG_DESCRIPTION="Fast passive subdomain enumeration tool"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@hasanzkan"
TERMUX_PKG_VERSION="2.17.0"
TERMUX_PKG_SRCURL="https://github.com/projectdiscovery/subfinder/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256="f9fffdfac6b9668eb8497e661a6ccd24cf83a0f459a41902ad0a782e63b39a2b"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_make() {
  termux_setup_golang

  cd "${TERMUX_PKG_SRCDIR}/cmd/subfinder"
  go build -v -ldflags="-s -w" -o "${TERMUX_PKG_BUILDDIR}/subfinder" .
}

termux_step_make_install() {
  install -Dm700 -t "${TERMUX_PREFIX}/bin" "${TERMUX_PKG_BUILDDIR}/subfinder"
}

TERMUX_PKG_HOMEPAGE=https://github.com/bogdanfinn/tls-client/
TERMUX_PKG_DESCRIPTION="A net/http.Client like HTTP Client with options to select specific client TLS Fingerprints to use for requests"
# LICENSE: BSD-4-Clause
TERMUX_PKG_LICENSE="custom"
TERMUX_PKG_LICENSE_FILE="LICENSE"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="1.9.2"
TERMUX_PKG_SRCURL="https://github.com/bogdanfinn/tls-client/archive/refs/tags/v$TERMUX_PKG_VERSION.tar.gz"
TERMUX_PKG_SHA256=009b08f8b1e0f62cfd1332cc77f2ad9bdd4391ed89235d96ec17c975326b85f1
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_make() {
	termux_setup_golang

	cd cffi_dist
	go build -buildmode=c-shared -o ./dist/lib-tls-client.so
}

termux_step_make_install() {
	install -Dm600 -t "${TERMUX_PREFIX}"/lib "$TERMUX_PKG_SRCDIR"/cffi_dist/dist/lib-tls-client.so
	install -Dm600 -t "${TERMUX_PREFIX}"/include "$TERMUX_PKG_SRCDIR"/cffi_dist/dist/lib-tls-client.h
}

TERMUX_PKG_HOMEPAGE=https://github.com/bogdanfinn/tls-client/
TERMUX_PKG_DESCRIPTION="Shared library for catopen/catgets/catclose of Bionic Libc"
# LICENSE: BSD-4-Clause
TERMUX_PKG_LICENSE="custom"
TERMUX_PKG_LICENSE_FILE="LICENSE"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="1.7.8"
TERMUX_PKG_SRCURL="https://github.com/bogdanfinn/tls-client/archive/refs/tags/v$TERMUX_PKG_VERSION.tar.gz"
TERMUX_PKG_SHA256=f3f1639c806c623d082f2ebc3f8ec698e068358af2c36af6d69d39f8c4921a43
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	termux_setup_golang

	go mod init || :
	go mod tidy
}

termux_step_make() {
	cd cffi_dist
	go build -buildmode=c-shared -o ./dist/lib-tls-client.so
}

termux_step_make_install() {
	install -Dm600 -t "${TERMUX_PREFIX}"/lib "$TERMUX_PKG_SRCDIR"/cffi_dist/dist/lib-tls-client.so
	install -Dm600 -t "${TERMUX_PREFIX}"/include "$TERMUX_PKG_SRCDIR"/cffi_dist/dist/lib-tls-client.h
}

TERMUX_PKG_HOMEPAGE=https://metacpan.org/dist/Net-SSLeay/
TERMUX_PKG_DESCRIPTION="Perl bindings for OpenSSL and LibreSSL"
TERMUX_PKG_LICENSE="Artistic-License-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=1.94
TERMUX_PKG_SRCURL=https://github.com/radiator-software/p5-net-ssleay/archive/refs/tags/${TERMUX_PKG_VERSION/-/_}.tar.gz
TERMUX_PKG_SHA256=a73aee174e400030ba10d78fa8c4cf60c4d1275302d66379c23271dc91c14e7c
TERMUX_PKG_DEPENDS="perl, openssl"
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_pre_configure() {
	if [ "${TERMUX_ON_DEVICE_BUILD}" = false ]; then
		termux_error_exit "This package doesn't support cross-compiling."
	fi
}

termux_step_configure() {
	OPENSSL_PREFIX=$TERMUX_PREFIX perl Makefile.PL PREFIX=$TERMUX_PREFIX
}

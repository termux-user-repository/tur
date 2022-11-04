TERMUX_PKG_HOMEPAGE=https://metacpan.org/dist/Net-SSLeay/
TERMUX_PKG_DESCRIPTION="Perl bindings for OpenSSL and LibreSSL"
TERMUX_PKG_LICENSE="Artistic-License-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=1.92
TERMUX_PKG_SRCURL=https://github.com/radiator-software/p5-net-ssleay/archive/refs/tags/$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=0f502c1c10884a31699ac0d58d01d6cb4ca18ae59cf626b16d3327f7eb952ca9
TERMUX_PKG_DEPENDS="perl, openssl"
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_configure() {
	perl Makefile.PL PREFIX=$TERMUX_PREFIX
}

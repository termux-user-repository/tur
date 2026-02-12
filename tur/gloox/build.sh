TERMUX_PKG_HOMEPAGE=https://camaya.net/gloox/
TERMUX_PKG_DESCRIPTION="A rock-solid, full-featured XMPP client library"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION=1.0.28
TERMUX_PKG_SRCURL=https://camaya.net/download/gloox-${TERMUX_PKG_VERSION}.tar.bz2
TERMUX_PKG_SHA256=591bd12c249ede0b50a1ef6b99ac0de8ef9c1ba4fd2e186f97a740215cc5966c
TERMUX_PKG_DEPENDS="openssl, zlib, gnutls, libgnutls"

termux_step_post_get_source() {
	# Fix C++11 list initialization error ({ 0 }) when compiler is forced into C++98 mode by gloox build system
	sed -i 's/{ 0 }/0/g' src/tlsopensslclient.cpp
	sed -i 's/{ 0 }/0/g' src/tlsopensslserver.cpp
}

termux_step_pre_configure() {
	# Force disable tests to avoid dependency on cppunit
	TERMUX_PKG_EXTRA_CONFIGURE_ARGS="--without-cppunit --with-openssl=$TERMUX_PREFIX --with-zlib=$TERMUX_PREFIX"
	
	# Avoid using -ansi which restricts to C++98
	CXXFLAGS+=" -std=c++11"
}

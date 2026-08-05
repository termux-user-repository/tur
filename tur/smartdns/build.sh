TERMUX_PKG_HOMEPAGE=https://github.com/pymumu/smartdns
TERMUX_PKG_DESCRIPTION="A local DNS server to obtain the fastest website IP for the best Internet experience, support DoT, DoH"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="48.4"
TERMUX_PKG_SRCURL=https://github.com/pymumu/smartdns/archive/refs/tags/Release$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=b07abba99e921f262ba47588e12f5b36dd849f79c0145542440eb6b7eed80553
TERMUX_PKG_DEPENDS="libandroid-glob, libc++, openssl"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_VERSION_SED_REGEXP='s/Release//'

termux_step_configure() {
	LDFLAGS+=" -landroid-glob"
}

termux_step_make() {
	make -j $TERMUX_PKG_MAKE_PROCESSES \
			PREFIX="$PREFIX" \
			SBINDIR="$PREFIX/bin" \
			SYSCONFDIR="$PREFIX/etc" \
			RUNSTATEDIR="$PREFIX/var/run"
}

termux_step_make_install() {
	make install -j $TERMUX_PKG_MAKE_PROCESSES \
			PREFIX="$PREFIX" \
			SBINDIR="$PREFIX/bin" \
			SYSCONFDIR="$PREFIX/etc" \
			RUNSTATEDIR="$PREFIX/var/run"
}

TERMUX_PKG_HOMEPAGE=https://github.com/pymumu/smartdns
TERMUX_PKG_DESCRIPTION="A local DNS server to obtain the fastest website IP for the best Internet experience, support DoT, DoH"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=43
TERMUX_PKG_SRCURL=https://github.com/pymumu/smartdns/archive/refs/tags/Release$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=2a5e7869603ecb7b0d94e153d938e798f0b8f260cc6062cc095a39116386d8b3
TERMUX_PKG_DEPENDS="libc++, openssl"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_configure() {
	:
}

termux_step_make() {
	make -j $TERMUX_MAKE_PROCESSES \
			PREFIX="$PREFIX" \
			SBINDIR="$PREFIX/bin" \
			SYSCONFDIR="$PREFIX/etc" \
			RUNSTATEDIR="$PREFIX/var/run"
}

termux_step_make_install() {
	make install -j $TERMUX_MAKE_PROCESSES \
			PREFIX="$PREFIX" \
			SBINDIR="$PREFIX/bin" \
			SYSCONFDIR="$PREFIX/etc" \
			RUNSTATEDIR="$PREFIX/var/run"
}

TERMUX_PKG_HOMEPAGE=http://aluigi.org/mytoolz.htm#morsegen
TERMUX_PKG_DESCRIPTION="Convert text file to ASCII morse code"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=0.2.1
TERMUX_PKG_SRCURL=http://deb.debian.org/debian/pool/main/m/morsegen/morsegen_$TERMUX_PKG_VERSION.orig.tar.gz
TERMUX_PKG_SHA256="1b5df992bf807aff5d9df067f596d0bfcbb481aa3841be0a5bf2a7d610014bc1"
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_make() {
	$CC $CFLAGS $TERMUX_PKG_SRCDIR/morsegen.c -o morsegen
}

termux_step_make_install() {
	install -Dm700 morsegen $TERMUX_PREFIX/bin/morsegen
}

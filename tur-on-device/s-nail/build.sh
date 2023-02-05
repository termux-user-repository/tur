TERMUX_PKG_HOMEPAGE="https://www.sdaoden.eu/code.html#s-nail"
TERMUX_PKG_DESCRIPTION="Portable mailx(1) with MIME and Maildir support"
TERMUX_PKG_LICENSE="ISC, BSD"
TERMUX_PKG_LICENSE_FILE="COPYING"
TERMUX_PKG_MAINTAINER="@flosnvjx"
TERMUX_PKG_VERSION="14.9.24"
TERMUX_PKG_SRCURL="https://github.com/sdaoden/s-mailx/archive/refs/tags/v$TERMUX_PKG_VERSION.tar.gz"
TERMUX_PKG_SHA256=b8b516b5b8d77ae21ebad88c6a202c1c931719c5e646d1f3f8070c023cf33ed6
TERMUX_PKG_DEPENDS="libidn2, libiconv, openssl, ncurses"
TERMUX_PKG_BUILD_DEPENDS="getconf"
TERMUX_PKG_RECOMMENDS="ed, vi, mime-support"
TERMUX_PKG_PROVIDES=mailx
TERMUX_PKG_CONFLICTS=mailx
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_MAKE_INSTALL_TARGET="DESTDIR=/ install"
## Use a dummy DESTDIR to avoid installing uninstall.sh to PREFIX/bin.

termux_step_configure() {
	make \
		VAL_PREFIX=$TERMUX_PREFIX \
		C_INCLUDE_PATH="$TERMUX_PREFIX/include" \
		LD_LIBRARY_PATH="$TERMUX_PREFIX/lib" \
		OPT_AUTOCC=no \
		OPT_CROSS_BUILD=yes \
		EXTRA_CFLAGS="$CPPFLAGS" \
		VERBOSE=yes \
		VAL_MAIL="$TERMUX_PREFIX"/var/spool/mail \
		VAL_MTA="$TERMUX_PREFIX"/bin/sendmail \
		VAL_SHELL="$TERMUX_PREFIX"/bin/sh \
		VAL_TMPDIR="$TERMUX_PREFIX"/tmp \
		VAL_PAGER=less \
		VAL_MIME_TYPES_SYS="$TERMUX_PREFIX"/etc/mime.types \
		VAL_MAILCAPS="$TERMUX_ANDROID_HOME/.mailcap:$TERMUX_PREFIX/etc/mailcap" \
		VAL_RANDOM="tls,libgetrandom,sysgetrandom,urandom,builtin" \
		OPT_NET=yes \
		OPT_USE_PKGSYS=no \
		OPT_TLS_ALL_ALGORITHMS=no \
		OPT_ALWAYS_UNICODE_LOCALE=yes \
		OPT_DOTLOCK=no \
		OPT_GSSAPI=no \
		OPT_SPAM_FILTER=no \
		config
	printf '%s\n' "make config. done."
}

termux_step_post_make_install() {
	mkdir -vp "$TERMUX_PREFIX/share/doc/$TERMUX_PKG_NAME"
	ln -vs "$TERMUX_PREFIX/bin/s-nail" "$TERMUX_PREFIX/bin/mailx"
	ln -vs "$TERMUX_PREFIX/share/man/man1/"{s-nail,mailx}.1.gz
	cp -v README NEWS THANKS -t "$TERMUX_PREFIX/share/doc/$TERMUX_PKG_NAME"
	mv -vt "$TERMUX_PREFIX/share/doc/$TERMUX_PKG_NAME" "$TERMUX_PREFIX/etc/$TERMUX_PKG_NAME.rc"
}

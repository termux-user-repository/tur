TERMUX_PKG_HOMEPAGE=http://www.garloff.de/kurt/linux/ddrescue/
TERMUX_PKG_DESCRIPTION="A dd(1) alternative without POSIX-correctness burden to ease daily shell scripting and data recovery"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_LICENSE_FILE="COPYING"
TERMUX_PKG_MAINTAINER="@flosnvjx"
#TERMUX_PKG_DEPENDS="openssl"
TERMUX_PKG_VERSION="1.99.12"
TERMUX_PKG_SRCURL="http://www.garloff.de/kurt/linux/ddrescue/dd_rescue-${TERMUX_PKG_VERSION}.tar.bz2"
TERMUX_PKG_SHA256=f304750aecf2b04a4798b26373a66483cf075e0a8e4619e78dc307e8f794c895
#TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_METHOD=repology
TERMUX_PKG_BUILD_IN_SRC=true
## do not build w/ lzo
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
ac_cv_header_lzo_lzo1x_h=no
"
TERMUX_PKG_EXTRA_MAKE_ARGS="
prefix=$TERMUX_PREFIX
INSTASROOT=
LIBDIR=$TERMUX_PREFIX/lib
"

termux_step_pre_configure() {
	EXTRA_CFLAGS="$CPPFLAGS"
	EXTRA_LDFLAGS="$LDFLAGS"
	autoreconf -fi

	sed -e '/^\.SS hash$/,/^\.SH EXIT STATUS$/d
		/^\.BI dd_rescue\\ \\-ATL\\ hash=md5:output,lzo=compress:bench,MD5:output\\ in\\ out\.lzo$/,/^infile nor to write the checksum to CHECKSUMS.sha512.$/d' -i dd_rescue.1
	perl -0pe 's%^(On successful completion,)$%\n.SH EXIT STATUS\n\1%gms' < dd_rescue.1 > man
	mv man dd_rescue.1
}

termux_step_post_make_install() {
	install -Dm600 -t "$TERMUX_PREFIX"/share/doc/$TERMUX_PKG_NAME README.*

	## plugins that test failed: https://github.com/termux/termux-packages/pull/12113#issuecomment-1257231811
	## remove these plugins at the moment
	rm $TERMUX_PREFIX/share/man/man1/ddr_{crypt,lzo}.1* || :
	rm $TERMUX_PREFIX/lib/libddr_{MD5,hash,crypt}.so || :
}

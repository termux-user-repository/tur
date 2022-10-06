TERMUX_PKG_HOMEPAGE="http://www.ucw.cz/gitweb/?p=xsv.git;a=summary"
TERMUX_PKG_DESCRIPTION="Utility to convert between formats, and rearrange fields on CSV/TSV/xSV input"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@flosnvjx"
TERMUX_PKG_VERSION=1.0.1+2
TERMUX_PKG_SRCURL="http://www.ucw.cz/gitweb/?p=xsv.git;a=snapshot;h=b2775106e771d248ff0568fbae0f7644296dc0ad;sf=tgz"
TERMUX_PKG_SHA256=f9a2b5ef07641faedd659fe08ca0b3576a38d26592d4ae4c637e48a97f1acf38
TERMUX_PKG_BUILD_DEPENDS="asciidoc"
TERMUX_PKG_DEPENDS="pcre"
TERMUX_PKG_CONFLICTS="xsv-rs"
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_make() {
	make PREFIX=$TERMUX_PREFIX \
	CFLAGS="-std=gnu99 -DVERSION='\"${TERMUX_PKG_VERSION%+*}\"' $CFLAGS" \
	CPPFLAGS="$CPPFLAGS" LDFLAGS="$LDFLAGS"

	if [[ "$TERMUX_ON_DEVICE_BUILD" = true ]];then
		make tests
	else
		echo skip check due to non-on-device build. >&2
	fi
}

termux_step_make_install() {
	make PREFIX=$TERMUX_PREFIX install
	install -vDm600 -t $TERMUX_PREFIX/share/doc/$TERMUX_PKG_NAME README*
}

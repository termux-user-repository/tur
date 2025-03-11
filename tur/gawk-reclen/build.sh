TERMUX_PKG_HOMEPAGE=https://gawkextlib.sourceforge.net/
TERMUX_PKG_DESCRIPTION="gawk(1) extension library for parsing input records in a fix-length manner"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@flosnvjx"
TERMUX_PKG_VERSION="1.0.1"
TERMUX_PKG_SRCURL="https://downloads.sourceforge.net/gawkextlib/$TERMUX_PKG_NAME-$TERMUX_PKG_VERSION.tar.gz"
TERMUX_PKG_SHA256=ad7631e2745d5fe3553e009e188ceaf4ff3a4653e4ce9baac731623d5decad77
TERMUX_PKG_DEPENDS="gawk"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="ac_cv_header_libintl_h=no"
TERMUX_PKG_AUTO_UPDATE=true

termux_step_post_make_install() {
	cd "$TERMUX_PKG_SRCDIR"
	install -Dm644 -t $TERMUX_PREFIX/share/doc/$TERMUX_PKG_NAME test/reclen.awk
}

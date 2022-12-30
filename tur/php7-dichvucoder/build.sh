TERMUX_PKG_HOMEPAGE=https://dichvucoder.com
TERMUX_PKG_DESCRIPTION="An extension supports running php file encoded/obfuscate by dichvucoder.com"
TERMUX_PKG_LICENSE="custom"
TERMUX_PKG_LICENSE_FILE="LICENSE"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=9.0.0
TERMUX_PKG_SRCURL=https://dichvucoder.com/Pe01u2929/dichvucoder.zip
TERMUX_PKG_SHA256=450655cfaed0316ecb3ba6db0b36e4b0c4f15f5547571a99c5a5c523e43ead99
TERMUX_PKG_DEPENDS="libandroid-execinfo, php7"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--enable-dichvucoder
"

termux_step_pre_configure() {
	$TERMUX_PREFIX/bin/phpize
	LDFLAGS+=" -Wl,--no-as-needed,-landroid-execinfo,-lm"
}

termux_step_post_make_install() {
	cp -f $TERMUX_PKG_BUILDER_DIR/LICENSE $TERMUX_PKG_SRCDIR
}

TERMUX_PKG_HOMEPAGE=https://dichvucoder.com
TERMUX_PKG_DESCRIPTION="An extension supports running php file encoded/obfuscate by dichvucoder.com"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=0.0.0
TERMUX_PKG_SRCURL=https://dichvucoder.com/Pe01u2929/dichvucoder.zip
TERMUX_PKG_SHA256=450655cfaed0316ecb3ba6db0b36e4b0c4f15f5547571a99c5a5c523e43ead99
TERMUX_PKG_DEPENDS="php7"

termux_step_pre_configure() {
	$TERMUX_PREFIX/bin/phpize
}

termux_step_post_make_install() {
	cp -f $TERMUX_PKG_BUILDER_DIR/LICENSE $TERMUX_PKG_SRCDIR
}

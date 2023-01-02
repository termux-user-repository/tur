TERMUX_PKG_HOMEPAGE=https://dichvucoder.com
TERMUX_PKG_DESCRIPTION="An extension supports running php file encoded/obfuscate by dichvucoder.com"
TERMUX_PKG_LICENSE="custom"
TERMUX_PKG_LICENSE_FILE="LICENSE"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=8.5.1
TERMUX_PKG_SRCURL=https://github.com/Dichvucoder/dgbaopro/raw/main/dgbaopro.zip
TERMUX_PKG_SHA256=04b20f5087b948e8aa5ab2ae4b59097f8d9defb288c11da9bd1f5471763592b3
TERMUX_PKG_DEPENDS="libandroid-execinfo, php7"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--enable-dgbaopro
"

termux_step_pre_configure() {
	$TERMUX_PREFIX/bin/phpize
	LDFLAGS+=" -Wl,--no-as-needed,-landroid-execinfo,-lm"
}

termux_step_post_make_install() {
	cp -f $TERMUX_PKG_BUILDER_DIR/LICENSE $TERMUX_PKG_SRCDIR
}

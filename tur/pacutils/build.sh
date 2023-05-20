TERMUX_PKG_HOMEPAGE=https://github.com/andrewgregory/pacutils
TERMUX_PKG_DESCRIPTION="Utilitization of libalpm(3) as C program to ease shell scripting"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_LICENSE_FILE="COPYING"
TERMUX_PKG_MAINTAINER="@flosnvjx"
TERMUX_PKG_VERSION=0.11.1
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=https://github.com/andrewgregory/pacutils/archive/refs/tags/v$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=e47c3a49eaa23a75473f563d3d868b2ac3e056dd57170149b4ba935538faf64e
TERMUX_PKG_DEPENDS="pacman, openssl, libandroid-glob"
TERMUX_PKG_BUILD_DEPENDS="perl"
TERMUX_PKG_BUILD_IN_SRC=true
#TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_TAG_TYPE="newest-tag"

termux_step_pre_configure() {
	CFLAGS+=" $CPPFLAGS"
	LDFLAGS+=" -landroid-glob"
}

termux_step_post_make_install() {
	cd "$TERMUX_PREFIX"

	rm -rf {include,share/man/man3}

	local util= disabledUtils=( paccapability paclog )
	for util in $disabledUtils;do
		rm bin/$util
		rm share/man/man?/$util.* || :
	done
}

TERMUX_PKG_HOMEPAGE="https://github.com/falconindy/expac"
TERMUX_PKG_DESCRIPTION="libalpm(3) database reporting utility"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@flosnvjx"
TERMUX_PKG_VERSION=10
TERMUX_PKG_SRCURL=https://github.com/falconindy/expac/archive/refs/tags/$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=77c074fea2e0a0f4fb0cd5aecb652c62520e67fc0c76256f950f1e3ca6916b97
TERMUX_PKG_DEPENDS="pacman, libandroid-glob"
#TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_TAG_TYPE="newest-tag"

termux_step_pre_configure() {

	## GPL text
	cp -v /usr/share/doc/coreutils/copyright -T $TERMUX_PKG_SRCDIR/LICENSE

	LDFLAGS+=" -landroid-glob"

}



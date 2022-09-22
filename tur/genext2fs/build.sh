TERMUX_PKG_HOMEPAGE=https://github.com/bestouff/genext2fs
TERMUX_PKG_DESCRIPTION="Build ext2 filesystem image without mounting for copying files (like mkfs.fat + mcopy in one go)"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@flosnvjx, @termux-user-repository"
TERMUX_PKG_VERSION=1.5.0
TERMUX_PKG_SRCURL=https://github.com/bestouff/genext2fs/archive/v$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=d3861e4fe89131bd21fbd25cf0b683b727b5c030c4c336fadcd738ada830aab0
TERMUX_PKG_DEPENDS="libarchive"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--sysconfdir=$TERMUX_PREFIX/etc
--mandir=$TERMUX_PREFIX/share/man
--localstatedir=$TERMUX_PREFIX/var
--enable-libarchive
"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_TAG_TYPE="newest-tag"

termux_step_pre_configure(){
	autoreconf -fi
}

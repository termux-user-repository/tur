TERMUX_PKG_HOMEPAGE=https://github.com/bestouff/genext2fs
TERMUX_PKG_DESCRIPTION="Build ext2 filesystem image without mounting for copying files (like mkfs.fat + mcopy in one go)"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@flosnvjx, @termux-user-repository"
TERMUX_PKG_VERSION="1.6.3"
TERMUX_PKG_SRCURL=https://github.com/bestouff/genext2fs/archive/v$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=e3503a5bae3fd4b5b2c2d4f49b5b7f8d08e7accb20ab28c0f9647389b2c8a079
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

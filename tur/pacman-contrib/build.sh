TERMUX_PKG_HOMEPAGE=https://gitlab.archlinux.org/pacman/pacman-contrib
TERMUX_PKG_DESCRIPTION="Additional libalpm utilities contributed by Arch community"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@flosnvjx"
TERMUX_PKG_VERSION=1.7.1
TERMUX_PKG_SRCURL="https://gitlab.archlinux.org/pacman/pacman-contrib/-/archive/v$TERMUX_PKG_VERSION/pacman-contrib-v$TERMUX_PKG_VERSION.tar.gz"
TERMUX_PKG_SHA256=81ad0af095fa2a686975bc11b4eb3b6602da60196e82819fb7a92f6fae5bf16d
TERMUX_PKG_DEPENDS="pacman"
TERMUX_PKG_BUILD_DEPENDS="asciidoc, perl, bsdtar"
TERMUX_PKG_RECOMMENDS="diffutils, bsdtar"
TERMUX_PKG_SUGGESTS="vim, mlocate, perl"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="--disable-git-version"
#TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_METHOD=repology

termux_step_pre_configure() {
	cd $TERMUX_PKG_SRCDIR
	export PKG_CONFIG_PATH="$TERMUX_PREFIX/share/pkgconfig"
	./autogen.sh
}

termux_step_post_make_install() {
	rm -rf $TERMUX_PREFIX/usr/lib/systemd

	## pactree -s may require `pacman-key --init`
	local disabledUtils=(checkupdates paclist)
	local util=
	for util in $disabledUtils;do
		rm $TERMUX_PREFIX/bin/$util
		rm $TERMUX_PREFIX/share/man/man8/$util.8* || :
		rm $TERMUX_PREFIX/share/zsh/site-functions/_$util || :
	done
}

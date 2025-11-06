TERMUX_PKG_HOMEPAGE=https://gitlab.archlinux.org/pacman/pacman-contrib
TERMUX_PKG_DESCRIPTION="Additional libalpm utilities contributed by Arch community"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="1.13.0"
TERMUX_PKG_SRCURL="https://gitlab.archlinux.org/pacman/pacman-contrib/-/archive/v$TERMUX_PKG_VERSION/pacman-contrib-v$TERMUX_PKG_VERSION.tar.gz"
TERMUX_PKG_SHA256=b6bf7b1efd8ab65f564db1a5efd76af7711de4be6b10faa68a7d6328a844afa4
TERMUX_PKG_DEPENDS="pacman"
TERMUX_PKG_BUILD_DEPENDS="asciidoc, perl, bsdtar"
TERMUX_PKG_RECOMMENDS="diffutils, bsdtar"
TERMUX_PKG_SUGGESTS="vim, mlocate, perl"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="--disable-git-version"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_METHOD=repology
TERMUX_PKG_SERVICE_SCRIPT=(
	'paccache' 'exec paccache -r 2>&1'
	'pacman-filesdb-refresh' 'exec pacman -Fy 2>&1'
)
TERMUX_PKG_RM_AFTER_INSTALL="
	lib
	bin/checkupdates
	bin/paclist
	share/man/man8/checkupdates.8
	share/man/man8/paclist.8
	share/zsh/site-functions/_checkupdates
	share/zsh/site-functions/_paclist
"

termux_step_pre_configure() {
	./autogen.sh
}

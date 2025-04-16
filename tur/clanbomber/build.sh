TERMUX_PKG_HOMEPAGE=https://www.nongnu.org/clanbomber
TERMUX_PKG_DESCRIPTION="The goal of ClanBomber is to blow away your opponents using bombs, but avoid being blown up yourself."
TERMUX_PKG_LICENSE="custom"
TERMUX_PKG_LICENSE_FILE="COPYING, LICENSE.DEJAVU"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
_COMMIT=b0f00ecc784d1cbef8c6672712fbeb0f03d324b3
_COMMIT_DATE=2022.07.03
TERMUX_PKG_VERSION="2.3-p${_COMMIT_DATE//./}"
TERMUX_PKG_GIT_BRANCH="master"
TERMUX_PKG_SRCURL=git+https://github.com/viti95/ClanBomber2
TERMUX_PKG_DEPENDS="sdl2, sdl2-image, sdl2-mixer, sdl2-ttf"

termux_step_post_get_source() {
	git fetch --unshallow
	git checkout $_COMMIT

	local date_="$(git log -1 --format=%cs | sed 's/-/./g')"
	if [ "$date_" != "$_COMMIT_DATE" ]; then
		echo -n "ERROR: The specified commit date \"$_COMMIT_DATE\""
		echo " is different from what is expected to be: \"$date_\""
		return 1
	fi
}

termux_step_pre_configure() {
	autoreconf -fvi
}

TERMUX_PKG_HOMEPAGE=https://github.com/IntinteDAO/Frabs
TERMUX_PKG_DESCRIPTION="An open source Abuse game asset augmented by community scripts and map"
TERMUX_PKG_LICENSE="custom"
TERMUX_PKG_LICENSE_FILE="LICENSE"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
_COMMIT=787b195c91538ee2c556cc574c74cedfc76357d7
_COMMIT_DATE=2021.08.27
TERMUX_PKG_VERSION=${_COMMIT_DATE//./}
TERMUX_PKG_SRCURL=git+https://github.com/IntinteDAO/fRaBs
TERMUX_PKG_GIT_BRANCH="master"
TERMUX_PKG_DEPENDS="abuse"
TERMUX_PKG_PLATFORM_INDEPENDENT=true

termux_step_post_get_source() {
	git fetch --unshallow
	git checkout $_COMMIT

	local version="$(git log -1 --format=%cs | sed 's/-/./g')"
	if [ "$version" != "$_COMMIT_DATE" ]; then
		echo -n "ERROR: The specified commit date \"$_COMMIT_DATE\""
		echo " is different from what is expected to be: \"$version\""
		return 1
	fi
}

termux_step_make_install() {
	mkdir -p $TERMUX_PREFIX/share/games/abuse-frabs/
	cp -Rf $TERMUX_PKG_SRCDIR/* $TERMUX_PREFIX/share/games/abuse-frabs/
	cat << EOF > $TERMUX_PREFIX/bin/abuse-frabs
#!$TERMUX_PREFIX/bin/env sh

exec $TERMUX_PREFIX/bin/abuse -datadir $TERMUX_PREFIX/share/games/abuse-frabs "\$@"

EOF
	chmod +x $TERMUX_PREFIX/bin/abuse-frabs
}

TERMUX_PKG_HOMEPAGE=https://github.com/magiblot/turbo
TERMUX_PKG_DESCRIPTION="An experimental text editor based on Scintilla and Turbo Vision"
TERMUX_PKG_LICENSE="custom"
TERMUX_PKG_LICENSE_FILE="COPYRIGHT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
_COMMIT=3db219eb1d681cc9fcbae8f3e6e9fe0943299ead
_COMMIT_DATE=2023.03.25
TERMUX_PKG_VERSION="0.0.1-git-${_COMMIT:0:8}"
TERMUX_PKG_GIT_BRANCH="master"
TERMUX_PKG_SRCURL=git+https://github.com/magiblot/turbo
TERMUX_PKG_DEPENDS="libandroid-support, libc++, ncurses"

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

termux_step_post_make_install() {
	rm -f $TERMUX_PREFIX/lib/libfmt.a
}

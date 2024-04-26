TERMUX_PKG_HOMEPAGE=https://github.com/polyzium/termbot
TERMUX_PKG_DESCRIPTION="A fully fledged terminal emulator in a Discord chat"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
_COMMIT=0f4b10382ccf9fe9a72c4021dda4fc78fb318738
_COMMIT_DATE=2022.09.02
TERMUX_PKG_VERSION=${_COMMIT_DATE//./}
TERMUX_PKG_SRCURL=git+https://github.com/polyzium/termbot
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_GIT_BRANCH="master"

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

termux_step_make() {
	termux_setup_golang

	go build -o termbot
}

termux_step_make_install() {
	install -Dm755 -t "${TERMUX_PREFIX}"/bin termbot
}

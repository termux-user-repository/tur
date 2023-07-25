TERMUX_PKG_HOMEPAGE=https://github.com/EionRobb/purple-discord
TERMUX_PKG_DESCRIPTION="A libpurple/Pidgin plugin for Discord"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@fervi"
_COMMIT=4a091883e646f2c103ae68c41d04b1b880e8d0bf
_COMMIT_DATE=2023.02.15
TERMUX_PKG_VERSION="0.9-p${_COMMIT_DATE//./}"
TERMUX_PKG_SRCURL=git+https://github.com/EionRobb/purple-discord
TERMUX_PKG_SHA256=b5715cfe5fa22f66d6b31ce176b5ce230b4effa31b293423a15c34ada880d28e
TERMUX_PKG_DEPENDS="finch | pidgin, libnss, libqrencode, glib, json-glib, zlib"
TERMUX_PKG_ANTI_DEPENDS="pidgin"
TERMUX_PKG_GIT_BRANCH=master
TERMUX_PKG_BUILD_IN_SRC=true

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

termux_step_pre_configure() {
	CFLAGS="${CFLAGS/-Oz/-O0}"
}

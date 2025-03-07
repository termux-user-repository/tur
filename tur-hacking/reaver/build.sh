TERMUX_PKG_HOMEPAGE="https://github.com/t6x/reaver-wps-fork-t6x"
TERMUX_PKG_DESCRIPTION="Reaver performs a brute force attack against an access point’s Wi-Fi Protected Setup pin number."
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
_COMMIT=926eb14143f76bcd24e9aee75279d1227e40e261
_VERSION="1.6.6"
_REVISION="r317"
TERMUX_PKG_VERSION="$_VERSION-$_REVISION.${_COMMIT:0:7}"
TERMUX_PKG_SRCURL="git+https://github.com/t6x/reaver-wps-fork-t6x"
TERMUX_PKG_GIT_BRANCH="master"
TERMUX_PKG_DEPENDS="libpcap, libnl"
TERMUX_PKG_RECOMMENDS="aircrack-ng"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--with-libpcap-include=$TERMUX_PREFIX/include
--with-libpcap-lib=$TERMUX_PREFIX/lib
--enable-libnl3
"

termux_step_post_get_source() {
	git fetch --unshallow
	git checkout $_COMMIT

	local version="$(printf "$_VERSION-r%d.%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short HEAD)")"
	if [ "$version" != "$TERMUX_PKG_VERSION" ]; then
		echo -n "ERROR: The specified version \"$TERMUX_PKG_VERSION\""
		echo " is different from what is expected to be: \"$version\""
		return 1
	fi

	mv src/* .
	sed -i 's/DESIRED_FLAGS="-Werror-unknown-warning-option -Wno-unused-but-set-variable"/DESIRED_FLAGS="-Wno-unused-but-set-variable"/g' configure
}

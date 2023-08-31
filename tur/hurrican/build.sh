TERMUX_PKG_HOMEPAGE=https://github.com/HurricanGame/Hurrican
TERMUX_PKG_DESCRIPTION="Freeware jump and shoot game created by Poke53280, based on the Turrican game series by Manfred Trenz"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@fervi"
_COMMIT=67da195a2fea7cb43202626a18f13357ac6adac2
_VERSION="1.0.9.3"
_REVISION="r756"
TERMUX_PKG_VERSION="$_VERSION-$_REVISION.${_COMMIT:0:7}"
TERMUX_PKG_SRCURL="git+https://github.com/HurricanGame/Hurrican"
TERMUX_PKG_GIT_BRANCH="master"
TERMUX_PKG_SHA256=a8e8c7a9a3a96c95524ae6a21f662e7052ca03a8274b164642a300b4dfe60be4
TERMUX_PKG_GROUPS="games"
TERMUX_PKG_DEPENDS="libc++, libepoxy, sdl2-mixer, sdl2, sdl2-image"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DSDL2_PATH=$TERMUX_PREFIX
-DFAST_TRIG=ON
"
TERMUX_PKG_RM_AFTER_INSTALL="
share/hurrican/lang/languages.zip
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

	local s=$(find . -type f ! -path '*/.git/*' -print0 | xargs -0 sha256sum | LC_ALL=C sort | sha256sum)
	if [[ "${s}" != "${TERMUX_PKG_SHA256}  "* ]]; then
		termux_error_exit "Checksum mismatch for source files."
	fi
}

termux_step_pre_configure() {
	export TERMUX_SRCDIR_SAVE=$TERMUX_PKG_SRCDIR
	TERMUX_PKG_SRCDIR=$TERMUX_PKG_SRCDIR/Hurrican
}

termux_step_post_configure() {
	TERMUX_PKG_SRCDIR=$TERMUX_SRCDIR_SAVE
}

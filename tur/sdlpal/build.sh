TERMUX_PKG_HOMEPAGE=https://sdlpal.github.io/sdlpal/
TERMUX_PKG_DESCRIPTION="SDL-based reimplementation of the classic Chinese-language RPG known as PAL"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
_COMMIT=3c85cd2b5d0297c2dc3d32df9b27e3ee1cdbf694
_COMMIT_DATE=2024.08.06
TERMUX_PKG_VERSION=2.0.${_COMMIT_DATE}
TERMUX_PKG_SRCURL="git+https://github.com/sdlpal/sdlpal"
TERMUX_PKG_GIT_BRANCH="master"
TERMUX_PKG_DEPENDS="libc++, opengl, sdl2"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_EXTRA_MAKE_ARGS="
-C unix
SDL_CONFIG=$TERMUX_PREFIX/bin/sdl2-config
USE_ALSA=0
"

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

termux_step_configure() {
	TERMUX_PKG_EXTRA_MAKE_ARGS+=" CC=$CC CXX=$CXX"
}

termux_step_make_install() {
	env -i PATH="$PATH" sudo apt update
	env -i PATH="$PATH" sudo apt install -y graphicsmagick-imagemagick-compat

	mkdir -p $TERMUX_PREFIX/{bin,share/applications,share/icons/hicolor/256x256/apps}
	cp $TERMUX_PKG_SRCDIR/unix/sdlpal $TERMUX_PREFIX/bin/
	cp $TERMUX_PKG_SRCDIR/unix/sdlpal.desktop $TERMUX_PREFIX/share/applications/
	convert $TERMUX_PKG_SRCDIR/Icon.png -resize 256x256 sdlpal.png
	cp sdlpal.png $TERMUX_PREFIX/share/icons/hicolor/256x256/apps/
}

TERMUX_PKG_HOMEPAGE=https://www.luanti.org
TERMUX_PKG_DESCRIPTION="An open source voxel game engine."
TERMUX_PKG_LICENSE="LGPL-2.1"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=2024.11.03
_COMMIT=9982c563730f294d404119a2b8ffe26073134884
TERMUX_PKG_SRCURL=git+https://github.com/minetest/minetest.git
TERMUX_PKG_GIT_BRANCH=master
TERMUX_PKG_SHA256=0aa7f0b08de6e7b74c522f62a354e88f8a291da53c4b0e38ca4f4cb10f6d2e86
# incomplete depends, i dont have time yet to write the perfect depends for this
TERMUX_PKG_DEPENDS="sdl2, libc++, openal-soft, libvorbis, libsqlite, freetype, libpng, libcurl, libandroid-spawn"

termux_step_pre_configure() {
	export LDFLAGS+=" -landroid-spawn"
}

termux_step_post_get_source() {
	git fetch --unshallow
	git checkout $_COMMIT

	local version="$(git log -1 --format=%cs | sed 's/-/./g')"
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

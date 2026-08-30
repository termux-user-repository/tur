TERMUX_PKG_HOMEPAGE=https://github.com/dosemu2/dosemu2
TERMUX_PKG_DESCRIPTION="Run DOS programs under linux."
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@stsp"
TERMUX_PKG_VERSION="2.0pre9-git"
TERMUX_PKG_REVISION=12
TERMUX_PKG_SRCURL=git+https://github.com/dosemu2/dosemu2
TERMUX_PKG_GIT_BRANCH=devel
_COMMIT=7a2b1c72dd3a851f105d3e40db2cda419804b1fa
TERMUX_PKG_SHA256=99709741eca94e0c0870602cee9fbb91914d4a9f368e2ffe44dab0d4988fb7b6
TERMUX_PKG_DEPENDS="comcom64, instfd, libandroid-posix-semaphore, libandroid-glob, slang, libao, fluidsynth, ladspa-sdk, libslirp, readline, json-c, libseccomp, libsearpc, sdl3, sdl3-ttf, fontconfig, fdpp, dj64dev"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--disable-landlock
--disable-solib
"

termux_step_post_get_source() {
	git fetch --unshallow
	git checkout "$_COMMIT"
	local s=$(git ls-files | xargs cat | sha256sum -b)
	if [[ "${s}" != "${TERMUX_PKG_SHA256} "* ]]; then
		termux_error_exit "Checksum mismatch for source files."
	fi
}

termux_step_pre_configure() {
	cd "$TERMUX_PKG_SRCDIR"
	./autogen.sh
	# switch off X plugin and use SDL instead
	sed -i -E 's/^X$//' plugin_list
}

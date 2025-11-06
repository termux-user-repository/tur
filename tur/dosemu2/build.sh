TERMUX_PKG_HOMEPAGE=https://github.com/dosemu2/dosemu2
TERMUX_PKG_DESCRIPTION="Run DOS programs under linux."
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@stsp"
TERMUX_PKG_VERSION="2.0pre9-git"
TERMUX_PKG_REVISION=8
TERMUX_PKG_SRCURL=git+https://github.com/dosemu2/dosemu2
TERMUX_PKG_GIT_BRANCH=devel
_COMMIT=36d7c7757a9d63c7456c2f682fb7388ea8462bbe
TERMUX_PKG_SHA256=3ccdcd722baf48cd4075beda0b331fdc04e422d85c423a5b4e4199e64f4b6645
TERMUX_PKG_BUILD_DEPENDS="libandroid-posix-semaphore, libandroid-glob, slang, libao, fluidsynth, ladspa-sdk, libslirp, libbsd, readline, json-c, libseccomp, libsearpc, sdl3, sdl3-ttf, fontconfig, fdpp, dj64dev"
TERMUX_PKG_DEPENDS="comcom64, instfd, libandroid-posix-semaphore, libandroid-glob, slang, libao, fluidsynth, ladspa-sdk, libslirp, libbsd, readline, json-c, libseccomp, libsearpc, sdl3, sdl3-ttf, fontconfig, fdpp, dj64dev"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--disable-landlock
--disable-solib
"

termux_step_post_get_source() {
	git fetch --unshallow
	git checkout $_COMMIT
	local s=$(git ls-files | xargs cat | sha256sum -b)
	if [[ "${s}" != "${TERMUX_PKG_SHA256} "* ]]; then
		termux_error_exit "Checksum mismatch for source files."
	fi
}

termux_step_pre_configure() {
	cd $TERMUX_PKG_SRCDIR
	./autogen.sh
	# switch off X plugin and use SDL instead
	sed -i -E 's/^X$//' plugin_list
}

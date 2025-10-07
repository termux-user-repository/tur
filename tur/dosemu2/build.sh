TERMUX_PKG_HOMEPAGE=https://github.com/dosemu2/dosemu2
TERMUX_PKG_DESCRIPTION="Run DOS programs under linux."
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@stsp"
TERMUX_PKG_VERSION="2.0pre9-git"
TERMUX_PKG_REVISION=6
TERMUX_PKG_SRCURL=git+https://github.com/dosemu2/dosemu2
TERMUX_PKG_GIT_BRANCH=devel
_COMMIT=1b3de44560587de5de6b73e701ecaadedb1ba645
TERMUX_PKG_SHA256=c2038b8259109872acdb91d4517d826481dfa7400fb9df37158c9f75b6dbdb44
TERMUX_PKG_BUILD_DEPENDS="libandroid-posix-semaphore, libandroid-glob, slang, libao, fluidsynth, ladspa-sdk, libslirp, libbsd, readline, json-c, libseccomp, libsearpc, sdl3, sdl3-ttf, fontconfig, fdpp, dj64dev"
TERMUX_PKG_DEPENDS="comcom64, instfd, libandroid-posix-semaphore, libandroid-glob, slang, libao, fluidsynth, ladspa-sdk, libslirp, libbsd, readline, json-c, libseccomp, libsearpc, sdl3, sdl3-ttf, fontconfig, fdpp, dj64dev"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--disable-landlock
--disable-solib
--disable-cpuemu-jit
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

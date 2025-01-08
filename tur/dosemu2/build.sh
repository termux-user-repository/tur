TERMUX_PKG_HOMEPAGE=https://github.com/dosemu2/dosemu2
TERMUX_PKG_DESCRIPTION="Run DOS programs under linux."
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@stsp"
TERMUX_PKG_VERSION="2.0pre9-git"
TERMUX_PKG_REVISION=2
TERMUX_PKG_SRCURL=git+https://github.com/dosemu2/dosemu2
TERMUX_PKG_GIT_BRANCH=devel
_COMMIT=58cd68c2bbbf1976bbb80d39c4ddd8edd2dd93ea
TERMUX_PKG_SHA256=e2fcd6e79091442f22fc61f24cac3c9e21dbe47df31ca3ae3f65b8dc457c3c72
TERMUX_PKG_BUILD_DEPENDS="libandroid-posix-semaphore, libandroid-glob, slang, libao, fluidsynth, ladspa-sdk, libslirp, libbsd, readline, json-c, libseccomp, libsearpc, fdpp, dj64dev"
TERMUX_PKG_DEPENDS="comcom64, instfd, libandroid-posix-semaphore, libandroid-glob, slang, libao, fluidsynth, ladspa-sdk, libslirp, libbsd, readline, json-c, libseccomp, libsearpc, fdpp, dj64dev"

termux_step_post_get_source() {
	git fetch --unshallow
	git checkout $_COMMIT
	local s=$(git archive --format=tar HEAD | sha256sum -b)
	if [[ "${s}" != "${TERMUX_PKG_SHA256} "* ]]; then
		termux_error_exit "Checksum mismatch for source files."
	fi
}

termux_step_pre_configure() {
	cd $TERMUX_PKG_SRCDIR
	./autogen.sh
}

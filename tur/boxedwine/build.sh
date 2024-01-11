TERMUX_PKG_HOMEPAGE=http://www.boxedwine.org/
TERMUX_PKG_DESCRIPTION="Boxedwine is an Linux and x86 CPU emulator that is specialized for running Wine."
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_LICENSE_FILE="license.txt"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
_COMMIT=963b6e524274c35ee0ff28126c825db7ee47b8a6
_VERSION="21.0.1"
_REVISION="r344"
TERMUX_PKG_VERSION="$_VERSION-$_REVISION-g${_COMMIT:0:8}"
TERMUX_PKG_SRCURL=git+https://github.com/danoon2/Boxedwine
TERMUX_PKG_GIT_BRANCH="master"
TERMUX_PKG_SHA256=007eb8e0db735c64839f90c3020ca117281b1f3e7176e02608e128d8f51f5d49
TERMUX_PKG_DEPENDS="glu, libc++, libcurl, libminizip, libx11, opengl, openssl, pulseaudio, sdl2, zlib"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_BLACKLISTED_ARCHES="i686"

termux_step_post_get_source() {
	git fetch --unshallow
	git checkout $_COMMIT

	local version="$(git describe --long --tags | sed 's/^v//;s/\([^-]*-g\)/r\1/')"
	if [ "$version" != "$TERMUX_PKG_VERSION" ]; then
		echo -n "ERROR: The specified version \"$TERMUX_PKG_VERSION\""
		echo " is different from what is expected to be: \"$version\""
		return 1
	fi

	local s=$(find . -type f ! -path '*/.git/*' -print0 | xargs -0 sha256sum | LC_ALL=C sort | sha256sum)
	if [[ "${s}" != "${TERMUX_PKG_SHA256}  "* ]]; then
		echo "$s"
		termux_error_exit "Checksum mismatch for source files."
	fi
}

termux_step_make() {
	uname_m=$TERMUX_ARCH
	if [ $TERMUX_ARCH = arm ]; then
		uname_m=armv7l
	fi

	cd ./project/linux
	if [ $TERMUX_ARCH = "aarch64" -o $TERMUX_ARCH = "x86_64" ]; then
		make multiThreaded uname_n=raspberrypi uname_m=${uname_m}
	else
		make jit uname_n=raspberrypi uname_m=${uname_m}
	fi
}

termux_step_make_install() {
	cd ./project/linux
	if [ $TERMUX_ARCH = "aarch64" -o $TERMUX_ARCH = "x86_64" ]; then
		cp Build/MultiThreaded/boxedwine ${TERMUX_PREFIX}/bin
	else
		cp Build/Jit/boxedwine ${TERMUX_PREFIX}/bin
	fi
	cd ../..
	local _DOCPATH="${TERMUX_PREFIX}/share/doc/${TERMUX_PKG_NAME}"
	mkdir -p "${_DOCPATH}"
	cp README.md changeLog.txt commandLine.txt docs/* "${_DOCPATH}"
}

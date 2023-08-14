TERMUX_PKG_HOMEPAGE=http://www.boxedwine.org/
TERMUX_PKG_DESCRIPTION="Boxedwine is an Linux and x86 CPU emulator that is specialized for running Wine."
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_LICENSE_FILE="license.txt"
TERMUX_PKG_MAINTAINER="@termux"
_GIT_HASH=963b6e524274c35ee0ff28126c825db7ee47b8a6
TERMUX_PKG_VERSION=23.0.2.20240107.${_GIT_HASH}
TERMUX_PKG_SRCURL=https://github.com/danoon2/Boxedwine/archive/${_GIT_HASH}.zip
TERMUX_PKG_SHA256=823e25082de74c1eb2d27325f615b12f318a3781eeaeb10576af616380c056a2
TERMUX_PKG_DEPENDS="sdl2, opengl, glu, openssl, boost, libminizip, pulseaudio, libcurl, libx11, zlib"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_BLACKLISTED_ARCHES="i686"

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

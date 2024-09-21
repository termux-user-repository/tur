TERMUX_PKG_HOMEPAGE=https://github.com/dnasdw/3dstool
TERMUX_PKG_DESCRIPTION="  "
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@tur"
TERMUX_PKG_VERSION=$(date +"%y%m%d")
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=git+https://github.com/john-peterson/3dstool
TERMUX_PKG_GIT_BRANCH=termux
TERMUX_PKG_DEPENDS=" cmake, capstone"
#TERMUX_PKG_BUILD_DEPENDS="libbthread, fdpp"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_FORCE_CMAKE=true
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DUSE_DEP=OFF
"
TERMUX_PKG_EXTRA_MAKE_ARGS=" VERBOSE=1"
if $TERMUX_ON_DEVICE_BUILD; then TERMUX_PKG_MAKE_PROCESSES=1;fi

if $TERMUX_ON_DEVICE_BUILD; then
echo " build works but script untested "
read
else
	echo " not tested off device"
	read
fi

termux_step_post_get_source() {

}

termux_step_pre_configure() {

}

termux_step_post_configure(){
	local CFLAGS+=" -w -Wno-error -Wfatal-errors"
}

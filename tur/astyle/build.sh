TERMUX_PKG_HOMEPAGE=https://astyle.sourceforge.net/
TERMUX_PKG_DESCRIPTION=" automatic indentation of source files "
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@tur"
TERMUX_PKG_VERSION=$(date +"%y%m%d")
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=svn+https://svn.code.sf.net/p/astyle/code/trunk/AStyle
#TERMUX_PKG_GIT_BRANCH=android
TERMUX_PKG_DEPENDS=" "
TERMUX_PKG_BUILD_DEPENDS=" clang"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="

"
TERMUX_PKG_EXTRA_MAKE_ARGS="
V=1 
-C build/clang
"
if $TERMUX_ON_DEVICE_BUILD; then TERMUX_PKG_MAKE_PROCESSES=1;fi

if $TERMUX_ON_DEVICE_BUILD; then
echo " tested and works but this script might need tweaks to run  "
read
else
	echo "not tested off device"
	read
fi

termux_step_post_get_source() {

}

termux_step_pre_configure() {

}

termux_step_post_configure(){
	local CFLAGS+=" -w -Wno-error -Wfatal-errors"
}

termux_step_make_install() {
	install -Dm755 -t "${TERMUX_PREFIX}"/build/clang/bin/astyle astyle
}

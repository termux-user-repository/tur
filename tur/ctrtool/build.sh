TERMUX_PKG_HOMEPAGE=https://github.com/3DSGuy/Project_CTR
TERMUX_PKG_DESCRIPTION=" unpack 3ds install files to run on device makerom -ciatocci *.cia -o out.3ds"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@tur"
TERMUX_PKG_VERSION=$(date +"%y%m%d")
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=git+https://github.com/3DSGuy/Project_CTR
#TERMUX_PKG_GIT_BRANCH=android
TERMUX_PKG_DEPENDS="libandroid-posix-semaphore, libandroid-shmem, libandroid-wordexp, gawk, flex, bison, lld, llvm"
#TERMUX_PKG_BUILD_DEPENDS="libbthread, fdpp"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="

"
TERMUX_PKG_EXTRA_MAKE_ARGS="V=1"
if $TERMUX_ON_DEVICE_BUILD; then TERMUX_PKG_MAKE_PROCESSES=1;fi

if !$TERMUX_ON_DEVICE_BUILD; then
echo " build and program tested and works but scripts untested might need tweaks "
read
fi

termux_step_post_get_source() {

}


termux_step_pre_configure() {

}

termux_step_post_configure(){
	local CFLAGS+=" -w -Wno-error -Wfatal-errors"
}

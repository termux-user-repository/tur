TERMUX_PKG_HOMEPAGE=https://github.com/dosemu2/dosemu2
TERMUX_PKG_DESCRIPTION="experimental build help wanted "
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@tur"
TERMUX_PKG_VERSION=$(date +"%y%m%d")
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=git+https://github.com/john-peterson/dosemu2
TERMUX_PKG_GIT_BRANCH=android
TERMUX_PKG_DEPENDS="libandroid-posix-semaphore, libandroid-shmem, libandroid-wordexp, gawk, flex, bison, lld, llvm"
#TERMUX_PKG_BUILD_DEPENDS="libbthread, fdpp"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--enable-plugins=fdpp,console,charsets
--enable-debug
--disable-searpc
--with-fdtarball=dosemu-freedos-1.0-bin.tgz
"
TERMUX_PKG_EXTRA_MAKE_ARGS="V=1"
if $TERMUX_ON_DEVICE_BUILD; then TERMUX_PKG_MAKE_PROCESSES=1;fi

if !$TERMUX_ON_DEVICE_BUILD; then
echo "only support on device so far edit me $0 to build better"
exit
fi

termux_step_post_get_source() {
wget http://prdownloads.sourceforge.net/dosemu/dosemu-freedos-1.0-bin.tgz
}

build_lbt(){
apt install libtool
git clone --depth=1 https://github.com/tux-mind/libbthread
cd libbthread
autoreconf -i
./configure --prefix=$PREFIX
make
cd ..
}

termux_step_pre_configure() {
	#build_lbt
	./autogen.sh
	export CFLAGS=" -w -target aarch64-none-linux-android28"
	export LIBS=" -lbthread -landroid-posix-semaphore -landroid-shmem -landroid-wordexp"
}

termux_step_post_configure(){
	local CFLAGS+=" -w -Wno-error -Wfatal-errors"
}

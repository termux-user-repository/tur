TERMUX_PKG_HOMEPAGE=https://trigger-rally.sourceforge.io
TERMUX_PKG_DESCRIPTION="A free 3D rally car racing game"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@fervi"
TERMUX_PKG_VERSION=0.6.6.1
TERMUX_PKG_REVISION=10
TERMUX_PKG_SRCURL=https://netcologne.dl.sourceforge.net/project/trigger-rally/trigger-${TERMUX_PKG_VERSION}/trigger-rally-${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=7f086e13d142b8bb07e808ab9111e5553309c1413532f56c754ce3cfa060cb04
TERMUX_PKG_DEPENDS="glew, libphysfs, libtinyxml2, libxi, libxinerama, libxxf86vm, make, ndk-multilib, openal-soft, openalut, pulseaudio, sdl2, sdl2-image"

termux_step_pre_configure(){
	export OPTIMS=""
	cd src
	make install
}

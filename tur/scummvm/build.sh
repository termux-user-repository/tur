TERMUX_PKG_HOMEPAGE=https://github.com/scummvm/scummvm
TERMUX_PKG_DESCRIPTION=" minimal working build on device add more engines and 3d graphics "
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@tur"
TERMUX_PKG_VERSION=$(date +"%y%m%d")
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=git+https://github.com/john-peterson/scummvm
TERMUX_PKG_GIT_BRANCH=termux
TERMUX_PKG_DEPENDS=" readline, sdl2, xorgproto"
#TERMUX_PKG_BUILD_DEPENDS="libbthread, fdpp"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--enable-text-console --disable-cloud --disable-lua --opengl-mode=none --disable-alsa --disable-all-engines --disable-detection-full --enable-engine=sci --disable-opengl-game --disable-tinygl --disable-libcurl --disable-enet --disable-sdlnet --disable-fluidsynth
"
TERMUX_PKG_EXTRA_MAKE_ARGS="V=1"
if $TERMUX_ON_DEVICE_BUILD; then TERMUX_PKG_MAKE_PROCESSES=1;fi

if !$TERMUX_ON_DEVICE_BUILD; then
echo "warning not tested off device "
read
fi

termux_step_post_get_source() {

}

termux_step_pre_configure() {

}

termux_step_post_configure(){
	local CFLAGS+=" -w -Wno-error -Wfatal-errors"
}

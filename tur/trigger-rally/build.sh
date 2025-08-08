TERMUX_PKG_HOMEPAGE=https://trigger-rally.sourceforge.io
TERMUX_PKG_DESCRIPTION="A free 3D rally car racing game"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@fervi"
TERMUX_PKG_VERSION=0.6.6.1
TERMUX_PKG_REVISION=11
TERMUX_PKG_SRCURL=https://netcologne.dl.sourceforge.net/project/trigger-rally/trigger-${TERMUX_PKG_VERSION}/trigger-rally-${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=7f086e13d142b8bb07e808ab9111e5553309c1413532f56c754ce3cfa060cb04
TERMUX_PKG_DEPENDS="glew, libphysfs, libtinyxml2, libxi, libxinerama, libxxf86vm, make, ndk-multilib, openal-soft, openalut, pulseaudio, sdl2, sdl2-image"

termux_step_pre_configure(){
	export LDFLAGS+=" -Wl,--no-as-needed,-lOpenSLES,--as-needed"
	export OPTIMS=""
	cd src
	make -j $TERMUX_PKG_MAKE_PROCESSES install bindir=$TERMUX_PREFIX/bin

}

termux_step_make_install(){
	install -Dm644 -t "${TERMUX_PREFIX}/share/applications" "${TERMUX_PKG_BUILDER_DIR}/trigger-rally.desktop"
install -Dm644 "$TERMUX_PKG_SRCDIR/data/icon/trigger-16.png"   "$TERMUX_PREFIX/share/icons/hicolor/16x16/apps/trigger-rally.png"
install -Dm644 "$TERMUX_PKG_SRCDIR/data/icon/trigger-22.png"   "$TERMUX_PREFIX/share/icons/hicolor/22x22/apps/trigger-rally.png"
install -Dm644 "$TERMUX_PKG_SRCDIR/data/icon/trigger-24.png"   "$TERMUX_PREFIX/share/icons/hicolor/24x24/apps/trigger-rally.png"
install -Dm644 "$TERMUX_PKG_SRCDIR/data/icon/trigger-32.png"   "$TERMUX_PREFIX/share/icons/hicolor/32x32/apps/trigger-rally.png"
install -Dm644 "$TERMUX_PKG_SRCDIR/data/icon/trigger-36.png"   "$TERMUX_PREFIX/share/icons/hicolor/36x36/apps/trigger-rally.png"
install -Dm644 "$TERMUX_PKG_SRCDIR/data/icon/trigger-48.png"   "$TERMUX_PREFIX/share/icons/hicolor/48x48/apps/trigger-rally.png"
install -Dm644 "$TERMUX_PKG_SRCDIR/data/icon/trigger-64.png"   "$TERMUX_PREFIX/share/icons/hicolor/64x64/apps/trigger-rally.png"
install -Dm644 "$TERMUX_PKG_SRCDIR/data/icon/trigger-72.png"   "$TERMUX_PREFIX/share/icons/hicolor/72x72/apps/trigger-rally.png"
install -Dm644 "$TERMUX_PKG_SRCDIR/data/icon/trigger-96.png"   "$TERMUX_PREFIX/share/icons/hicolor/96x96/apps/trigger-rally.png"
install -Dm644 "$TERMUX_PKG_SRCDIR/data/icon/trigger-128.png"  "$TERMUX_PREFIX/share/icons/hicolor/128x128/apps/trigger-rally.png"
install -Dm644 "$TERMUX_PKG_SRCDIR/data/icon/trigger-192.png"  "$TERMUX_PREFIX/share/icons/hicolor/192x192/apps/trigger-rally.png"
install -Dm644 "$TERMUX_PKG_SRCDIR/data/icon/trigger-256.png"  "$TERMUX_PREFIX/share/icons/hicolor/256x256/apps/trigger-rally.png"
install -Dm644 "$TERMUX_PKG_SRCDIR/data/icon/trigger-rally-icons.svg" "$TERMUX_PREFIX/share/icons/hicolor/scalable/apps/trigger-rally.svg"

}

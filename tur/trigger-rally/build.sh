TERMUX_PKG_HOMEPAGE=https://trigger-rally.sourceforge.io
TERMUX_PKG_DESCRIPTION="A free 3D rally car racing game"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@fervi"
TERMUX_PKG_VERSION=0.6.6.1
TERMUX_PKG_REVISION=11
TERMUX_PKG_SRCURL=https://downloads.sourceforge.net/trigger-rally/trigger-rally-${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=7f086e13d142b8bb07e808ab9111e5553309c1413532f56c754ce3cfa060cb04
TERMUX_PKG_DEPENDS="glew, libphysfs, libtinyxml2, libxi, libxinerama, libxxf86vm, openal-soft, openalut, pulseaudio, sdl2, sdl2-image, trigger-rally-data"
TERMUX_PKG_GROUPS="games"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_EXTRA_MAKE_ARGS="prefix=$TERMUX_PREFIX bindir=$TERMUX_PREFIX/bin"

termux_step_pre_configure() {
	TERMUX_PKG_SRCDIR+="/src"
	TERMUX_PKG_BUILDDIR="$TERMUX_PKG_SRCDIR"
}

termux_step_post_make_install() {
	local _top_srcdir="${TERMUX_PKG_SRCDIR%/*}"
	install -Dm644 -t "$TERMUX_PREFIX/share/applications" "$TERMUX_PKG_BUILDER_DIR/trigger-rally.desktop"
	local size
	for size in 16 22 24 32 36 48 64 72 96 128 192 256; do
		install -Dm644 "$_top_srcdir/data/icon/trigger-${size}.png" \
			"$TERMUX_PREFIX/share/icons/hicolor/${size}x${size}/apps/trigger-rally.png"
	done
	install -Dm644 "$_top_srcdir/data/icon/trigger-rally-icons.svg" \
		"$TERMUX_PREFIX/share/icons/hicolor/scalable/apps/trigger-rally.svg"
	install -Dm644 "$_top_srcdir/data/icon/trigger-128.png" \
		"$TERMUX_PREFIX/share/pixmaps/trigger-rally.png"
}

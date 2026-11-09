TERMUX_PKG_HOMEPAGE="https://neverball.org/"
TERMUX_PKG_DESCRIPTION="A 3D arcade game with a ball"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_LICENSE_FILE="LICENSE.md"
TERMUX_PKG_MAINTAINER="@IntinteDAO"
TERMUX_PKG_VERSION="1.6.0"
TERMUX_PKG_SRCURL="https://neverball.org/neverball-${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256="73fe63cca4f96e2d355480d03bc0b2904e83a0abdf65fe8c52db5cc3cca88fa0"
TERMUX_PKG_DEPENDS="libjpeg-turbo, libphysfs, libpng, libvorbis, neverball-data, opengl, sdl2 | sdl2-compat, sdl2-ttf"
TERMUX_PKG_GROUPS="games"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_EXTRA_MAKE_ARGS="DATADIR=$TERMUX_PREFIX/share/neverball ENABLE_NLS=0"

termux_step_make_install() {
	# Install binaries
	install -Dm755 -t "$TERMUX_PREFIX/bin" neverball neverputt mapc

	# Install data (excluding source .map files)
	mkdir -p "$TERMUX_PREFIX/share/neverball"
	tar -cf - --exclude='*.map' data | tar -xf - -C "$TERMUX_PREFIX/share/neverball" --strip-components=1

	# Install desktop files
	install -Dm644 -t "$TERMUX_PREFIX/share/applications" dist/neverball.desktop dist/neverputt.desktop

	# Install icons
	for app in neverball neverputt; do
		for size in 16 24 32 48 64 128 256 512; do
			install -Dm644 "dist/${app}_${size}.png" "$TERMUX_PREFIX/share/icons/hicolor/${size}x${size}/apps/${app}.png"
		done
		install -Dm644 "dist/${app}_128.png" "$TERMUX_PREFIX/share/pixmaps/${app}.png"
	done

	# Install man pages
	install -Dm644 -t "$TERMUX_PREFIX/share/man/man6" dist/neverball.6 dist/neverputt.6
	install -Dm644 -t "$TERMUX_PREFIX/share/man/man1" dist/mapc.1
}

TERMUX_PKG_HOMEPAGE="https://www.scummvm.org/"
TERMUX_PKG_DESCRIPTION="Virtual machine for classic graphical point-and-click adventure games"
TERMUX_PKG_LICENSE="GPL-3.0-or-later"
TERMUX_PKG_MAINTAINER="@IntinteDAO"
TERMUX_PKG_VERSION="2026.4.0"
TERMUX_PKG_SRCURL="https://downloads.scummvm.org/frs/scummvm/${TERMUX_PKG_VERSION}/scummvm-${TERMUX_PKG_VERSION}.tar.xz"
TERMUX_PKG_SHA256=cd660b34104da7f85ed0a11b7c6c2320c629bb87ee297935711ebc1e09731f12
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_DEPENDS="faad2, fluidsynth, freetype, glew, glu, liba52, libcurl, libflac, libiconv, libjpeg-turbo, libmad, libmpeg2, libpng, libtheora, libvorbis, opengl, sdl2 | sdl2-compat, sdl2-net, zlib"
TERMUX_PKG_GROUPS="games"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--disable-seq-midi
--disable-alsa
"

termux_step_pre_configure() {
	LDFLAGS+=" -Wl,--no-as-needed -lGLESv2 -lGL -Wl,--as-needed"
}

termux_step_configure() {
	"$TERMUX_PKG_SRCDIR/configure" \
		--prefix="$TERMUX_PREFIX" \
		--host="$TERMUX_ARCH-linux" \
		--backend=sdl \
		--enable-release \
		--disable-debug \
		--with-sdl-prefix="$TERMUX_PREFIX" \
		$TERMUX_PKG_EXTRA_CONFIGURE_ARGS
}

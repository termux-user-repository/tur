TERMUX_PKG_HOMEPAGE=https://www.openclonk.org/
TERMUX_PKG_DESCRIPTION="Multiplayer action game of strategy, tactics, and skill"
TERMUX_PKG_LICENSE="ISC"
TERMUX_PKG_MAINTAINER="@IntinteDAO"
TERMUX_PKG_VERSION=8.1
TERMUX_PKG_SRCURL="https://github.com/openclonk/openclonk/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=fea0cd473334c9adf74a8930c42c78b8c2eb9255e267976a700910e07d2a0506
TERMUX_PKG_AUTO_UPDATE=false
TERMUX_PKG_DEPENDS="freetype, glew, libc++, libjpeg-turbo, libpng, libx11, libxrandr, miniupnpc, openclonk-data, opengl, sdl2 | sdl2-compat, sdl2-mixer, zlib"
TERMUX_PKG_BUILD_DEPENDS="pkg-config"
TERMUX_PKG_HOSTBUILD=true
TERMUX_PKG_GROUPS="games"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DIMPORT_NATIVE_TOOLS=$TERMUX_PKG_HOSTBUILD_DIR/NativeToolsExport.cmake
-DAudio_TK=SDL_Mixer
-DHAVE_BACKWARD=OFF
-DUSE_GCC_STYLE_LTCG=OFF
"

termux_step_host_build() {
	termux_setup_cmake
	termux_setup_ninja
	cmake -G Ninja \
		-DCMAKE_BUILD_TYPE=Release \
		-DHEADLESS_ONLY=ON \
		-DAudio_TK=none \
		"$TERMUX_PKG_SRCDIR"
	ninja c4group
}

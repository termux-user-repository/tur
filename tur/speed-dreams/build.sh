TERMUX_PKG_HOMEPAGE="https://speed-dreams.net/"
TERMUX_PKG_DESCRIPTION="3D cross-platform motorsport simulation and racing game"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@IntinteDAO"
TERMUX_PKG_VERSION="2.4.2"
TERMUX_PKG_SRCURL="https://github.com/Sparky-OS/speed-dreams-code/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256="1a8d7dc417ead7586db0538058d15d65e29ab9766489b9cc903dab5a1d4f0401"
TERMUX_PKG_DEPENDS="cjson, glu, libcurl, libenet, libjpeg-turbo, libminizip, libpng, libvorbis, libx11, libxmu, libxrandr, openal-soft, opengl, openscenegraph, plib, rhash, sdl2, sdl2-mixer, speed-dreams-data, sqlite, zlib"
TERMUX_PKG_GROUPS="games"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DOpenGL_GL_PREFERENCE=LEGACY
-DOPTION_TRACKEDITOR=OFF
-DOPTION_OFFICIAL_ONLY=ON
-DOPTION_3RDPARTY_EXPAT=ON
-DOPTION_OSGGRAPH=ON
"

termux_step_pre_configure() {
	export LDFLAGS+=" -Wl,-rpath=${TERMUX_PREFIX}/lib/games/speed-dreams-2/lib"
}

termux_step_post_get_source() {
	git clone --depth 1 https://forge.a-lec.org/speed-dreams/freesolid.git freesolid
	git clone --depth 1 --branch v2.4.2 https://forge.a-lec.org/speed-dreams/speed-dreams-data.git speed-dreams-data
}

termux_step_post_make_install() {
	mkdir -p "${TERMUX_PREFIX}/bin"
	for exe in speed-dreams-2 sd2-accc sd2-nfs2ac sd2-nfsperf sd2-trackgen; do
		ln -sf "../games/${exe}" "${TERMUX_PREFIX}/bin/${exe}"
	done
}

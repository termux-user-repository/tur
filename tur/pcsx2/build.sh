TERMUX_PKG_HOMEPAGE=https://pcsx2.net
TERMUX_PKG_DESCRIPTION="A PlayStation 2 emulator"
TERMUX_PKG_LICENSE="GPL-3.0-or-later"
TERMUX_PKG_MAINTAINER="@IntinteDAO"
TERMUX_PKG_VERSION="2.2.0"
TERMUX_PKG_SRCURL=git+https://github.com/PCSX2/pcsx2
TERMUX_PKG_GIT_BRANCH="v${TERMUX_PKG_VERSION}"
TERMUX_PKG_DEPENDS="dbus, ffmpeg, libandroid-shmem, libandroid-spawn, libcurl, libjpeg-turbo, liblz4, libpcap, libpng, libsndfile, libwebp, opengl, qt6-qtbase, qt6-qtsvg, qt6-qttools, sdl2, shaderc, vulkan-headers, vulkan-loader, zlib, zstd"
TERMUX_PKG_BUILD_DEPENDS="extra-cmake-modules, pkg-config"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DCMAKE_SYSTEM_NAME=Linux
-DDISABLE_ADVANCED_SIMD=ON
-DENABLE_LTO=OFF
-DPACKAGE_MODE=ON
-DQT_BUILD=ON
-DUSE_VULKAN=ON
-DUSE_BACKTRACE=OFF
-DHOST_PAGE_SIZE=4096
-DHOST_CACHE_LINE_SIZE=64
"

termux_step_post_get_source() {
	git submodule update --init --recursive
}

termux_step_pre_configure() {
	CXXFLAGS+=" -DFMT_CONSTEVAL="
	LDFLAGS+=" -landroid-shmem -landroid-spawn"
}

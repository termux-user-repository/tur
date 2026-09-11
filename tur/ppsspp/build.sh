TERMUX_PKG_HOMEPAGE=https://www.ppsspp.org/
TERMUX_PKG_DESCRIPTION="PlayStation Portable emulator"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="1.20.4"
TERMUX_PKG_GIT_BRANCH="v${TERMUX_PKG_VERSION}"
TERMUX_PKG_SRCURL="git+https://github.com/hrydgard/ppsspp"
TERMUX_PKG_DEPENDS="sdl2, sdl2-ttf, fontconfig, libcurl, glew, libpng, rapidjson, miniupnpc, zstd, zlib, libzip, libsnappy, libcpufeatures, ffmpeg, spirv-tools"
TERMUX_PKG_BUILD_DEPENDS="extra-cmake-modules, libglvnd-dev, vulkan-headers, spirv-headers"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DCMAKE_SYSTEM_NAME=Linux
-DBUILD_TESTING=OFF
-DUSING_EGL=ON
-DUSING_FBDEV=OFF
-DUSING_GLES2=ON
-DUSING_X11_VULKAN=ON
-DUSE_WAYLAND_WSI=OFF
-DUSE_VULKAN_DISPLAY_KHR=OFF
-DUSING_QT_UI=OFF
-DMOBILE_DEVICE=OFF
-DHEADLESS=ON
-DATLAS_TOOL=ON
-DUNITTEST=OFF
-DSIMULATOR=OFF
-DLIBRETRO=OFF
-DUSE_LIBNX=OFF
-DUSE_FFMPEG=ON
-DUSE_DISCORD=OFF
-DUSE_MINIUPNPC=ON
-DUSE_SYSTEM_SNAPPY=ON
-DUSE_SYSTEM_FFMPEG=ON
-DUSE_SYSTEM_FREETYPE=ON
-DUSE_SYSTEM_LIBCHDR=OFF
-DUSE_SYSTEM_LIBZIP=ON
-DUSE_SYSTEM_LIBSDL2=ON
-DUSE_SYSTEM_LIBPNG=ON
-DUSE_SYSTEM_RAPIDJSON=ON
-DUSE_SYSTEM_ZSTD=ON
-DUSE_SYSTEM_MINIUPNPC=ON
-DUSE_ASAN=OFF
-DUSE_UBSAN=OFF
-DUSE_CCACHE=OFF
-DUSE_NO_MMAP=OFF
-DGOLD=OFF
"

termux_step_pre_configure() {
	# owokitty magic (do not call me owokitty in final version comments,
	# Tomjo2000 doesn't like that and it's probably weird)
	# this is my way of saying this is too hard to explain in one
	# paragraph and you are not expected to understand this code
	# (similar to the patch in the luanti package,
	# see there for more professional comment which I spent
	# more hours writing)
	find \
		"$TERMUX_PKG_SRCDIR"/Common/GPU \
		"$TERMUX_PKG_SRCDIR"/Common/MsgHandler.h \
		"$TERMUX_PKG_SRCDIR"/Common/Log.h \
		"$TERMUX_PKG_SRCDIR"/ppsspp_config.h \
		"$TERMUX_PKG_SRCDIR"/ext/naett \
		"$TERMUX_PKG_SRCDIR"/Qt \
		"$TERMUX_PKG_SRCDIR"/UI \
		-type f -print0 | xargs -0 sed -i \
		-e 's/\([^A-Za-z0-9_]__ANDROID\)\(__[^A-Za-z0-9_]\)/\1__DISABLING_THIS_BECAUSE_IT_IS_FOR_BUILDING_AN_APK\2/g' \
		-e 's/\([^A-Za-z0-9_]__ANDROID\)__$/\1_DISABLING_THIS_BECAUSE_IT_IS_FOR_BUILDING_AN_APK__/g'
}

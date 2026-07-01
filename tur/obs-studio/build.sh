TERMUX_PKG_HOMEPAGE=https://obsproject.com
TERMUX_PKG_DESCRIPTION="Free and open source software for live streaming and screen recording"
TERMUX_PKG_LICENSE="GPL-2.0-or-later"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=(
	"32.1.2"
	"5.7.3"
	"2.23.4"
)
_COMMIT=ea04212e4bbadd077f9e6038758c4e4779c24fa3
TERMUX_PKG_SRCURL=(
	"https://github.com/obsproject/obs-studio/archive/refs/tags/${TERMUX_PKG_VERSION[0]}.tar.gz"
	"https://github.com/obsproject/obs-websocket/archive/refs/tags/${TERMUX_PKG_VERSION[1]}.tar.gz"
	"https://github.com/obsproject/obs-browser/archive/${_COMMIT}.tar.gz"
)
TERMUX_PKG_SHA256=(
	b4a59410cddb46d0e31df1ee13b8ec66f30862d7e980c1a8c4e3b5d16fae6053
	5e9f06aae32a8ac0f94886e8caa5947ad7da41670169c9ee1a08e28cf53c65f5
	932bca40aa70b2ff1663c8e9e1183874e01f73cf55822fe324e91261b9116ace
)
TERMUX_PKG_DEPENDS="ffmpeg, libcurl, libfdk-aac, libjansson, mesa, pulseaudio, qt6-qtbase, qt6-qtsvg, qrcodegen, librnnoise, libx11, libxcb, libxkbcommon, zlib, glib, libuuid, fontconfig, freetype, libx264, vulkan-loader, libxext, libxfixes, libxcomposite, libxinerama, libxrandr, libxrender, libxcursor, libxdamage, libandroid-glob, libandroid-spawn"
TERMUX_PKG_BUILD_DEPENDS="extra-cmake-modules, swig, glslang, pkg-config, nlohmann-json, websocketpp, simde, uthash, libasio, libwayland, vlc-qt, python,libdatachannel, libfdk-aac, luajit, speexdsp, librnnoise, mbedtls-static, python, libcef-for-brow6el-dev"
TERMUX_PKG_SUGGESTS="vlc-qt, luajit, python,libdatachannel, librnnoise, libfdk-aac, speexdsp, libcef-for-brow6el"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DENABLE_AJA=OFF
-DENABLE_DECKLINK=OFF
-DENABLE_JACK=OFF
-DENABLE_SNDIO=OFF
-DENABLE_V4L2=OFF
-DENABLE_VST=OFF
-DENABLE_ALSA=OFF
-DENABLE_PIPEWIRE=OFF
-DENABLE_WAYLAND=ON
-DENABLE_UI=ON
-DENABLE_WEBRTC=ON
-DENABLE_WEBSOCKET=ON
-DENABLE_LIBFDK=ON
-DENABLE_RNNOISE=ON
-DENABLE_SCRIPTING_PYTHON=ON
-DENABLE_FREETYPE=ON
-DENABLE_NEW_MPEGTS_OUTPUT=OFF
-DENABLE_FFMPEG_NVENC=OFF
-DENABLE_TEST_INPUT=OFF
-DENABLE_RELOCATABLE=OFF
-DENABLE_PORTABLE_CONFIG=OFF
-DOBS_COMPILE_DEPRECATION_AS_WARNING=OFF
-DCMAKE_INSTALL_BINDIR=bin
-DCMAKE_INSTALL_LIBDIR=lib
-DCMAKE_INSTALL_INCLUDEDIR=include
-DCMAKE_INSTALL_DATAROOTDIR=share
-DCMAKE_PLATFORM_NO_VERSIONED_SONAME=OFF
-Dqrcodegencpp_DIR=$TERMUX_PREFIX/lib/cmake/qrcodegencpp
-Dwebsocketpp_DIR=$TERMUX_PREFIX/lib/cmake/websocketpp
-DUUID_INCLUDE_DIR=$TERMUX_PREFIX/include
-DUUID_LIBRARY=$TERMUX_PREFIX/lib/libuuid.so
"

#Error 1: CMake error : "cef_version.h cannot be read"
#Obs browser excepts it to be in CEF_ROOT_DIR,so try move or copy or link "$TERMUX_PREFIX/opt/libcef-for-brow6el-dev/include/version.h" to "$TERMUX_PREFIX/opt/libcef-for-brow6el-dev"
#PS: Changing CEF_ROOT_DIR to point $TERMUX_PREFIX/opt/libcef-for-brow6el-dev/include insted, will throw this error: "fatal error: 'include/cef_app.h' file not found during build time, atleast it did for me in local/on device build"

#Error 2:CMake error: Missing libcef_dll_wrapper.a
#Build Solution I found during local/ on-device build:
#cd $TERMUX_PREFIX/opt/libcef-for-brow6el-dev
#cmake -B build -DCMAKE_SYSTEM_PROCESSOR=arm64 -DPROJECT_ARCH=arm64
#Build it.
#After getting the libcef_dll_wrapper.a update the path below of CEF_LIBRARY_WRAPPER_RELEASE

TERMUX_PKG_EXTRA_CONFIGURE_ARGS+="
-DENABLE_BROWSER=ON
-DCEF_INCLUDE_DIR=$TERMUX_PREFIX/opt/libcef-for-brow6el
-DCEF_ROOT_DIR=$TERMUX_PREFIX/opt/libcef-for-brow6el-dev
-DCEF_LIBRARY_WRAPPER_RELEASE=$TERMUX_PREFIX/path-to-wherever-this-is->/libcef_dll_wrapper.a
"

termux_step_post_get_source() {
	# Remove the empty placeholder folders
	rm -rf plugins/obs-websocket plugins/obs-browser

	# Move the extracted GitHub folders into their respective locations
	mv "obs-websocket-${TERMUX_PKG_VERSION[1]}" plugins/obs-websocket
	mv "obs-browser-${_COMMIT}" plugins/obs-browser
}

termux_step_pre_configure() {
	export LDFLAGS+=" -lm -landroid-glob -landroid-spawn"
}

TERMUX_PKG_HOMEPAGE="https://obsproject.com"
TERMUX_PKG_DESCRIPTION="Free and open source software for video recording and live streaming"
TERMUX_PKG_LICENSE="GPL-2.0-or-later"
TERMUX_PKG_MAINTAINER="@lumaparallax"
TERMUX_PKG_VERSION="32.1.1"
TERMUX_PKG_SRCURL="git+https://github.com/obsproject/obs-studio.git"
TERMUX_PKG_GIT_BRANCH="${TERMUX_PKG_VERSION}"

TERMUX_PKG_DEPENDS="ffmpeg, libcurl, libdatachannel, libfdk-aac, libjansson, luajit, vlc, mbedtls, mesa, nlohmann-json, pulseaudio, python, qt6-qtbase, qt6-qtsvg, qrcodegen, librnnoise, speexdsp, websocketpp, libwayland, libx11, libxcb, libxkbcommon, simde, uthash, libva, zlib, glib, libuuid, fontconfig, freetype, libdrm, libx264, libasio, vulkan-loader, libxext, libxfixes, libxcomposite, libxinerama, libxrandr, libxrender, libxcursor, libxdamage, libandroid-glob, libandroid-spawn, libandroid-shmem, libcef-for-brow6el, libcef-for-brow6el-dev"

TERMUX_PKG_BUILD_DEPENDS="extra-cmake-modules, swig, mbedtls-static, glslang, pkg-config"

TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DENABLE_BROWSER=ON
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
"

termux_step_post_get_source() {
	git submodule update --init --recursive

	echo "Patching obs-browser submodule..."
	cd plugins/obs-browser
	patch -p1 -i "$TERMUX_PKG_BUILDER_DIR/0012-obs-browser-optimisation.diff"
	cd ../..

	echo "Patching obs-websocket submodule..."
	cd plugins/obs-websocket
	patch -p1 -i "$TERMUX_PKG_BUILDER_DIR/0007-obs-websocket.diff"
	cd ../../../

}

termux_step_pre_configure() {
	export LDFLAGS="${LDFLAGS} -lm -landroid-glob -landroid-spawn -landroid-shmem"

	# Ensure CMake finds Termux-installed packages
	TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" -Dqrcodegencpp_DIR=$TERMUX_PREFIX/lib/cmake/qrcodegencpp"
	TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" -Dwebsocketpp_DIR=$TERMUX_PREFIX/lib/cmake/websocketpp"\

	TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" -DUUID_INCLUDE_DIR=$TERMUX_PREFIX/include"
	TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" -DUUID_LIBRARY=$TERMUX_PREFIX/lib/libuuid.so"

	export CMAKE_PREFIX_PATH="$TERMUX_PREFIX"
}

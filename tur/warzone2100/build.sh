TERMUX_PKG_HOMEPAGE=https://wz2100.net/
TERMUX_PKG_DESCRIPTION="A free and open source 3D real-time strategy game"
TERMUX_PKG_LICENSE="GPL-2.0-or-later"
TERMUX_PKG_MAINTAINER="@IntinteDAO"
TERMUX_PKG_VERSION=4.7.0
TERMUX_PKG_SRCURL=https://github.com/Warzone2100/warzone2100/releases/download/${TERMUX_PKG_VERSION}/warzone2100_src.tar.xz
TERMUX_PKG_SHA256=95ee4d5b88680ea1b1cf230b67ea84028e08a2458b84605ac9f7fb9eb97c4e37
TERMUX_PKG_DEPENDS="fribidi, freetype, gettext, harfbuzz, libcurl, libjpeg-turbo, libogg, libopus, libphysfs, libpng, libprotobuf, libsodium, libsqlite, libtheora, libvorbis, libzip, openal-soft, sdl3, vulkan-loader, warzone2100-data, zlib"
TERMUX_PKG_BUILD_DEPENDS="pkg-config, shaderc, vulkan-headers, vulkan-loader-generic"
TERMUX_PKG_RECOMMENDS="warzone2100-video"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_TAG_TYPE=latest-release-tag
TERMUX_PKG_GROUPS="games"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DCMAKE_INSTALL_BINDIR=bin
-DCMAKE_INSTALL_DATADIR=share
-DCMAKE_INSTALL_DOCDIR=share/doc/$TERMUX_PKG_NAME
-DWZ_DATADIR=$TERMUX_PREFIX/share/warzone2100
-DENABLE_DOCS=OFF
-DENABLE_DISCORD=OFF
-DWZ_ENABLE_BACKEND_VULKAN=ON
-DWZ_ENABLE_BASIS_UNIVERSAL=OFF
-DWZ_ENABLE_WARNINGS_AS_ERRORS=OFF
-DWZ_USE_SYSTEM_LIBJPEG_TURBO=ON
-DWZ_FORCE_MINIMAL_OPUSFILE=ON
"

termux_step_pre_configure() {
	termux_setup_protobuf
	TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" -DProtobuf_PROTOC_EXECUTABLE=$(command -v protoc)"
	if command -v glslc > /dev/null 2>&1; then
		TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" -DVulkan_GLSLC_EXECUTABLE=$(command -v glslc)"
	fi
}

termux_step_post_make_install() {
	termux_download \
		"https://github.com/Warzone2100/wz-sequences/releases/download/v3/standard-quality-en-sequences.wz" \
		"$TERMUX_PREFIX/share/warzone2100/sequences.wz" \
		"SKIP_CHECKSUM"
}

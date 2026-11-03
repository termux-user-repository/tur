TERMUX_PKG_HOMEPAGE=https://wz2100.net/
TERMUX_PKG_DESCRIPTION="A free and open source 3D real-time strategy game"
TERMUX_PKG_LICENSE="GPL-2.0-or-later"
TERMUX_PKG_MAINTAINER="@IntinteDAO"
TERMUX_PKG_VERSION=4.7.0
TERMUX_PKG_SRCURL=(
	"https://github.com/Warzone2100/warzone2100/releases/download/${TERMUX_PKG_VERSION}/warzone2100_src.tar.xz"
	"https://github.com/Warzone2100/wz-sequences/releases/download/v3/standard-quality-en-sequences.wz"
)
TERMUX_PKG_SHA256=(
	"95ee4d5b88680ea1b1cf230b67ea84028e08a2458b84605ac9f7fb9eb97c4e37"
	"142ae905be288cca33357a49f42b884c190e828fc0b1b1773ded5dff774f41a3"
)
TERMUX_PKG_DEPENDS="fribidi, freetype, gettext, harfbuzz, libcurl, libjpeg-turbo, libogg, libopus, libphysfs, libpng, libprotobuf, libsodium, libsqlite, libtheora, libvorbis, libzip, openal-soft, sdl3, vulkan-loader, warzone2100-data, zlib"
TERMUX_PKG_BUILD_DEPENDS="pkg-config, vulkan-headers, vulkan-loader-generic"
TERMUX_PKG_RECOMMENDS="warzone2100-video"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_GROUPS="games"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DENABLE_DOCS=OFF
-DWZ_ENABLE_BASIS_UNIVERSAL=OFF
-DWZ_ENABLE_WARNINGS_AS_ERRORS=OFF
-DWZ_USE_SYSTEM_LIBJPEG_TURBO=ON
"

termux_extract_src_archive() {
	mkdir -p "$TERMUX_PKG_SRCDIR"
	tar -xf "$TERMUX_PKG_CACHEDIR/warzone2100_src.tar.xz" -C "$TERMUX_PKG_SRCDIR" --strip-components=1
}

termux_step_pre_configure() {
	termux_setup_protobuf
	export PATH="$NDK/shader-tools/linux-x86_64:$PATH"
}

termux_step_post_make_install() {
	install -Dm644 "$TERMUX_PKG_CACHEDIR/standard-quality-en-sequences.wz" \
		"$TERMUX_PREFIX/share/warzone2100/sequences.wz"
}

TERMUX_PKG_HOMEPAGE=https://openarena.ws
TERMUX_PKG_DESCRIPTION="OpenArena game engine"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION=0.8.8.20260412
TERMUX_PKG_SRCURL=https://github.com/OpenArena/engine/archive/95c63426c896b2f6277ee940f053a649dd97364a.tar.gz
TERMUX_PKG_SHA256=3bbd517fbf1e49e701a786adab56032108bf082ccf9915a003ca9ed9c8639db0
TERMUX_PKG_DEPENDS="libcurl, libjpeg-turbo, libxmp, openal-soft, openarena-data, opusfile, sdl2, zlib, libx11"
TERMUX_PKG_GROUPS="games"
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_pre_configure() {
	if [ "$TERMUX_ARCH" = "i686" ]; then
		CFLAGS+=" -DC_ONLY -DNO_VM_COMPILED"
	fi
}

termux_step_make() {
	local oa_arch="$TERMUX_ARCH"
	local extra_flags=""
	if [ "$oa_arch" = "i686" ]; then
		oa_arch="x86"
		extra_flags="HAVE_VM_COMPILED=false"
	fi

	make -j $TERMUX_PKG_MAKE_PROCESSES \
		PLATFORM=linux ARCH="$oa_arch" $extra_flags \
		BUILD_CLIENT=1 BUILD_SERVER=1 USE_CURL=1 USE_MUMBLE=0 \
		USE_CODEC_VORBIS=1 USE_CODEC_XMP=1 USE_CODEC_OPUS=1 USE_LOCAL_HEADERS=0
}

termux_step_make_install() {
	local oa_arch="$TERMUX_ARCH"
	if [ "$oa_arch" = "i686" ]; then
		oa_arch="x86"
	fi
	local build_dir="build/release-linux-${oa_arch}"

	install -Dm755 "$build_dir"/openarena* "$build_dir"/oa_ded* -t "$TERMUX_PREFIX/libexec/openarena/"
	mkdir -p "$TERMUX_PREFIX/bin"
	ln -sf "$TERMUX_PREFIX/libexec/openarena/openarena"* "$TERMUX_PREFIX/bin/openarena"
	ln -sf "$TERMUX_PREFIX/libexec/openarena/oa_ded"* "$TERMUX_PREFIX/bin/openarena-ded"

	install -Dm644 -t "$TERMUX_PREFIX/share/applications" "$TERMUX_PKG_BUILDER_DIR/openarena.desktop"
	install -Dm644 misc/quake3-tango.png "$TERMUX_PREFIX/share/icons/hicolor/256x256/apps/openarena.png"

	termux_download \
		"https://downloads.sourceforge.net/project/oarena/openarena-${TERMUX_PKG_VERSION%.*}.zip" \
		"$TERMUX_PKG_TMPDIR/openarena-${TERMUX_PKG_VERSION%.*}.zip" \
		"5a8faf7f5b51f351b0a1618c06b6b98a5f1a6758f1d39818de2c87df2a0bac4a"

	mkdir -p "$TERMUX_PREFIX/share/openarena"
	unzip -oq "$TERMUX_PKG_TMPDIR/openarena-${TERMUX_PKG_VERSION%.*}.zip" "openarena-${TERMUX_PKG_VERSION%.*}/baseoa/*" -d "$TERMUX_PKG_TMPDIR"
	cp -r "$TERMUX_PKG_TMPDIR/openarena-${TERMUX_PKG_VERSION%.*}/baseoa" "$TERMUX_PREFIX/share/openarena"
	chmod -R a+rX "$TERMUX_PREFIX/share/openarena"
}

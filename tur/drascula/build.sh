TERMUX_PKG_HOMEPAGE=https://www.scummvm.org/
TERMUX_PKG_DESCRIPTION="Classic 2D point and click comedy adventure game"
TERMUX_PKG_LICENSE="custom"
TERMUX_PKG_LICENSE_FILE="readme.txt"
TERMUX_PKG_MAINTAINER="@IntinteDAO"
TERMUX_PKG_VERSION=1.0
TERMUX_PKG_SRCURL=(
	"https://downloads.scummvm.org/frs/extras/Drascula_%20The%20Vampire%20Strikes%20Back/drascula-${TERMUX_PKG_VERSION}.zip"
	"https://downloads.scummvm.org/frs/extras/Drascula_%20The%20Vampire%20Strikes%20Back/drascula-audio-mp3-2.0.zip"
)
TERMUX_PKG_SHA256=(
	b731f6cb5a22ba8b4c3b3362f570b9a10a67b6cb0b395394b19a94b36e4e42de
	32bdb6d5163e538ffe20f6320e20e0b24050823be516775364be629ab1b52eee
)
TERMUX_PKG_DEPENDS="scummvm"
TERMUX_PKG_GROUPS="games"
TERMUX_PKG_PLATFORM_INDEPENDENT=true
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_get_source() {
	mkdir -p "$TERMUX_PKG_SRCDIR"
	termux_download_src_archive
	local url
	for url in "${TERMUX_PKG_SRCURL[@]}"; do
		unzip -q -o -d "$TERMUX_PKG_SRCDIR" "$TERMUX_PKG_CACHEDIR/$(basename "$url")"
	done
}

termux_step_make_install() {
	local gamedir="$TERMUX_PREFIX/share/scummvm/drascula"
	mkdir -p "$gamedir" "$TERMUX_PREFIX/bin"
	cp "$TERMUX_PKG_SRCDIR/Packet.001" "$gamedir/"
	cp -r "$TERMUX_PKG_SRCDIR/audio" "$gamedir/"

	install -Dm644 "$TERMUX_PKG_BUILDER_DIR/drascula.png" \
		"$TERMUX_PREFIX/share/pixmaps/drascula.png"
	install -Dm644 "$TERMUX_PKG_BUILDER_DIR/drascula.desktop" \
		"$TERMUX_PREFIX/share/applications/drascula.desktop"

	cat <<- EOF > "$TERMUX_PREFIX/bin/drascula"
		#!$TERMUX_PREFIX/bin/sh
		exec scummvm -p "$gamedir" drascula "\$@"
	EOF
	chmod 0755 "$TERMUX_PREFIX/bin/drascula"
}

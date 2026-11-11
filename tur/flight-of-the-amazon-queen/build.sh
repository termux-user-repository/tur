TERMUX_PKG_HOMEPAGE=https://www.scummvm.org/
TERMUX_PKG_DESCRIPTION="Classic 2D point and click fantasy adventure game"
TERMUX_PKG_LICENSE="custom"
TERMUX_PKG_LICENSE_FILE="readme.txt"
TERMUX_PKG_MAINTAINER="@IntinteDAO"
TERMUX_PKG_VERSION=1.1
TERMUX_PKG_SRCURL="https://downloads.scummvm.org/frs/extras/Flight%20of%20the%20Amazon%20Queen/FOTAQ_Talkie-${TERMUX_PKG_VERSION}.zip"
TERMUX_PKG_SHA256=a25cdd5e003a0a5e402af99b218cc7ea81ad032cb36b8c05df3bd1167038d8a8
TERMUX_PKG_DEPENDS="scummvm"
TERMUX_PKG_GROUPS="games"
TERMUX_PKG_PLATFORM_INDEPENDENT=true
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_get_source() {
	mkdir -p "$TERMUX_PKG_SRCDIR"
	termux_download_src_archive
	unzip -q -d "$TERMUX_PKG_SRCDIR" "$TERMUX_PKG_CACHEDIR/$(basename "$TERMUX_PKG_SRCURL")"
}

termux_step_make_install() {
	local gamedir="$TERMUX_PREFIX/share/scummvm/flight-of-the-amazon-queen"
	mkdir -p "$gamedir" "$TERMUX_PREFIX/bin"
	cp "$TERMUX_PKG_SRCDIR/queen.1c" "$gamedir/"

	install -Dm644 "$TERMUX_PKG_BUILDER_DIR/flight-of-the-amazon-queen.png" \
		"$TERMUX_PREFIX/share/pixmaps/flight-of-the-amazon-queen.png"
	install -Dm644 "$TERMUX_PKG_BUILDER_DIR/flight-of-the-amazon-queen.desktop" \
		"$TERMUX_PREFIX/share/applications/flight-of-the-amazon-queen.desktop"

	cat <<- EOF > "$TERMUX_PREFIX/bin/flight-of-the-amazon-queen"
		#!$TERMUX_PREFIX/bin/sh
		exec scummvm -p "$gamedir" queen "\$@"
	EOF
	chmod 0755 "$TERMUX_PREFIX/bin/flight-of-the-amazon-queen"
	ln -sfT flight-of-the-amazon-queen "$TERMUX_PREFIX/bin/queen"
}

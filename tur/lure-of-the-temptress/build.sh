TERMUX_PKG_HOMEPAGE=https://www.scummvm.org/
TERMUX_PKG_DESCRIPTION="Classic 2D point and click fantasy adventure game"
TERMUX_PKG_LICENSE="custom"
TERMUX_PKG_LICENSE_FILE="README"
TERMUX_PKG_MAINTAINER="@IntinteDAO"
TERMUX_PKG_VERSION=1.1
TERMUX_PKG_SRCURL="https://downloads.scummvm.org/frs/extras/Lure%20of%20the%20Temptress/lure-${TERMUX_PKG_VERSION}.zip"
TERMUX_PKG_SHA256=f3178245a1483da1168c3a11e70b65d33c389f1f5df63d4f3a356886c1890108
TERMUX_PKG_DEPENDS="scummvm"
TERMUX_PKG_GROUPS="games"
TERMUX_PKG_PLATFORM_INDEPENDENT=true
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_make_install() {
	local gamedir="$TERMUX_PREFIX/share/scummvm/lure-of-the-temptress"
	mkdir -p "$gamedir" "$TERMUX_PREFIX/bin"
	cp "$TERMUX_PKG_SRCDIR"/disk* "$gamedir/"

	install -Dm644 "$TERMUX_PKG_BUILDER_DIR/lure-of-the-temptress.png" \
		"$TERMUX_PREFIX/share/pixmaps/lure-of-the-temptress.png"
	install -Dm644 "$TERMUX_PKG_BUILDER_DIR/lure-of-the-temptress.desktop" \
		"$TERMUX_PREFIX/share/applications/lure-of-the-temptress.desktop"

	cat <<- EOF > "$TERMUX_PREFIX/bin/lure-of-the-temptress"
		#!$TERMUX_PREFIX/bin/sh
		exec scummvm -p "$gamedir" lure "\$@"
	EOF
	chmod 0755 "$TERMUX_PREFIX/bin/lure-of-the-temptress"
	ln -sfT lure-of-the-temptress "$TERMUX_PREFIX/bin/lure"
}

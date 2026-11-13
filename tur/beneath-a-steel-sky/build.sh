TERMUX_PKG_HOMEPAGE=https://www.scummvm.org/
TERMUX_PKG_DESCRIPTION="Classic 2D point and click science fiction adventure game"
TERMUX_PKG_LICENSE="custom"
TERMUX_PKG_LICENSE_FILE="readme.txt"
TERMUX_PKG_MAINTAINER="@IntinteDAO"
TERMUX_PKG_VERSION=1.2
TERMUX_PKG_SRCURL="https://downloads.scummvm.org/frs/extras/Beneath%20a%20Steel%20Sky/bass-cd-${TERMUX_PKG_VERSION}.zip"
TERMUX_PKG_SHA256=53209b9400eab6fd7fa71518b2f357c8de75cfeaa5ba57024575ab79cc974593
TERMUX_PKG_DEPENDS="scummvm"
TERMUX_PKG_GROUPS="games"
TERMUX_PKG_PLATFORM_INDEPENDENT=true
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_make_install() {
	local gamedir="$TERMUX_PREFIX/share/scummvm/beneath-a-steel-sky"
	mkdir -p "$gamedir" "$TERMUX_PREFIX/bin"
	cp "$TERMUX_PKG_SRCDIR"/sky.* "$gamedir/"

	install -Dm644 "$TERMUX_PKG_BUILDER_DIR/beneath-a-steel-sky.svg" \
		"$TERMUX_PREFIX/share/icons/hicolor/scalable/apps/beneath-a-steel-sky.svg"
	install -Dm644 "$TERMUX_PKG_BUILDER_DIR/beneath-a-steel-sky.svg" \
		"$TERMUX_PREFIX/share/pixmaps/beneath-a-steel-sky.svg"
	install -Dm644 "$TERMUX_PKG_BUILDER_DIR/beneath-a-steel-sky.desktop" \
		"$TERMUX_PREFIX/share/applications/beneath-a-steel-sky.desktop"

	cat <<- EOF > "$TERMUX_PREFIX/bin/beneath-a-steel-sky"
		#!$TERMUX_PREFIX/bin/sh
		exec scummvm -p "$gamedir" sky "\$@"
	EOF
	chmod 0755 "$TERMUX_PREFIX/bin/beneath-a-steel-sky"
	ln -sfT beneath-a-steel-sky "$TERMUX_PREFIX/bin/sky"
}

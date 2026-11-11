TERMUX_PKG_HOMEPAGE="https://github.com/KelvinShadewing/supertux-advance"
TERMUX_PKG_DESCRIPTION="A complete reimagining of SuperTux for the GBA era"
TERMUX_PKG_LICENSE="AGPL-3.0"
TERMUX_PKG_MAINTAINER="@IntinteDAO"
_COMMIT=cb51c39235b5bd99ad899ba9e14592292f517c75
TERMUX_PKG_VERSION=2026.01.07
TERMUX_PKG_SRCURL="https://github.com/KelvinShadewing/supertux-advance/archive/${_COMMIT}.tar.gz"
TERMUX_PKG_SHA256=5de5b6311634a1f2b63d5603a398baf439831900f4e874c52580c56d1180fb34
TERMUX_PKG_AUTO_UPDATE=false
TERMUX_PKG_DEPENDS="brux"
TERMUX_PKG_PLATFORM_INDEPENDENT=true

termux_step_make_install() {
	local INSTALL_DIR=$TERMUX_PREFIX/share/supertux-advance
	mkdir -p $INSTALL_DIR
	cp -a $TERMUX_PKG_SRCDIR/* $INSTALL_DIR/
	rm -rf $INSTALL_DIR/{contrib,docs}

	mkdir -p $TERMUX_PREFIX/bin
	cat > $TERMUX_PREFIX/bin/supertux-advance <<- EOF
		#!$TERMUX_PREFIX/bin/sh
		cd $INSTALL_DIR
		exec brux game.brx "\$@"
	EOF
	chmod 0755 $TERMUX_PREFIX/bin/supertux-advance

	install -Dm644 $TERMUX_PKG_SRCDIR/icon.png $TERMUX_PREFIX/share/icons/hicolor/32x32/apps/supertux-advance.png
	install -Dm644 $TERMUX_PKG_SRCDIR/icon.png $TERMUX_PREFIX/share/pixmaps/supertux-advance.png

	cat > $TERMUX_PREFIX/share/applications/supertux-advance.desktop <<- EOF
		[Desktop Entry]
		Name=SuperTux Advance
		Comment=A complete reimagining of SuperTux for the GBA era
		Exec=supertux-advance
		Icon=supertux-advance
		Terminal=false
		Type=Application
		Categories=Game;ActionGame;
	EOF
}

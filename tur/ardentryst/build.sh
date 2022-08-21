TERMUX_PKG_HOMEPAGE=https://github.com/ardentryst/ardentryst
TERMUX_PKG_DESCRIPTION="Ardentryst is an action/RPG sidescoller, focused not just on fighting, but on story, and character development."
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@fervi"
TERMUX_PKG_VERSION=20201007
TERMUX_PKG_SRCURL=https://github.com/ardentryst/ardentryst/archive/refs/heads/master.zip
TERMUX_PKG_SHA256=f7c32e8a220f9b2b0b94f7d4a3326a9ad5368cfea687a2a059c5fb279e61d025
TERMUX_PKG_DEPENDS="python, python-pygame, python-future"
TERMUX_PKG_PLATFORM_INDEPENDENT=true

termux_step_pre_configure(){

	# Create Directories
	mkdir -p $TERMUX_PREFIX/share/pixmaps
	mkdir -p $TERMUX_PREFIX/share/applications
	mkdir -p $TERMUX_PREFIX/share/games/ardentryst

	# Menu preparation
	cp $TERMUX_PKG_SRCDIR/icon.png $TERMUX_PREFIX/share/pixmaps/ardentryst.png
	mv $TERMUX_PKG_SRCDIR/Ardentryst.desktop $TERMUX_PREFIX/share/applications

	# Deletion of unnecessary files
	rm $TERMUX_PKG_SRCDIR/INSTALL.md
	rm $TERMUX_PKG_SRCDIR/ardentryst
	rm $TERMUX_PKG_SRCDIR/install.sh

	# Creation of the executable file
	printf "#!$TERMUX_PREFIX/bin/bash\n\ncd $TERMUX_PREFIX/share/games/ardentryst\n$TERMUX_PREFIX/bin/python $TERMUX_PREFIX/share/games/ardentryst/ardentryst.py" > $TERMUX_PREFIX/bin/ardentryst
	chmod 0755 $TERMUX_PREFIX/bin/ardentryst

	# Install data files
	cp -R * $TERMUX_PREFIX/share/games/ardentryst

}

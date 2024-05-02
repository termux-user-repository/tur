TERMUX_PKG_HOMEPAGE=https://github.com/ardentryst/ardentryst
TERMUX_PKG_DESCRIPTION="Ardentryst is an action/RPG sidescoller, focused not just on fighting, but on story, and character development."
# LICENSE: GPL-3.0, Creative-Commons-3.0
TERMUX_PKG_LICENSE="custom"
TERMUX_PKG_LICENSE_FILE="COPYING, COPYING.data"
TERMUX_PKG_MAINTAINER="@fervi"
TERMUX_PKG_VERSION=20230615
TERMUX_PKG_SRCURL=https://github.com/ardentryst/ardentryst/archive/7b66716d99b63ad0fa5794931fd39115b1d2056b.zip
TERMUX_PKG_SHA256=bf44bb121d0cb852213723cc301220f8a7c4ec3b99ded45cbb3d81b27fb9b2a4
TERMUX_PKG_DEPENDS="python, python-pygame, python-future"
TERMUX_PKG_ANTI_BUILD_DEPENDS="python, python-pygame, python-future"
TERMUX_PKG_PLATFORM_INDEPENDENT=true
TERMUX_PKG_AUTO_UPDATE=false

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

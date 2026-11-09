TERMUX_SUBPKG_DESCRIPTION="A 3D mini golf game"
TERMUX_SUBPKG_DEPEND_ON_PARENT=false
TERMUX_SUBPKG_DEPENDS="libjpeg-turbo, libphysfs, libpng, libvorbis, neverball-data, opengl, sdl2 | sdl2-compat, sdl2-ttf"
TERMUX_SUBPKG_INCLUDE="
bin/neverputt
share/applications/neverputt.desktop
share/icons/hicolor/*/apps/neverputt.png
share/man/man6/neverputt.6*
share/pixmaps/neverputt.png
"

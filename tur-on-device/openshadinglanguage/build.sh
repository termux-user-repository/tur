TERMUX_PKG_HOMEPAGE=https://github.com/AcademySoftwareFoundation/OpenShadingLanguage
TERMUX_PKG_DESCRIPTION="Advanced shading language for production GI renderers"
TERMUX_PKG_LICENSE="BSD 3-Clause"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="1.14.7.0"
TERMUX_PKG_REVISION=2
TERMUX_PKG_SRCURL="https://github.com/AcademySoftwareFoundation/OpenShadingLanguage/releases/download/v$TERMUX_PKG_VERSION/OSL-$TERMUX_PKG_VERSION.tar.gz"
TERMUX_PKG_SHA256=45b2b9de1bae6854fb8af0d332c3266898871d95741bdb6abe8178cd6d01aef2
TERMUX_PKG_DEPENDS="freetype, imath, libc++, libpng, libtiff, ncurses, openimageio, qt6-qtbase, zlib"
# OSL does not support 32-bit
TERMUX_PKG_EXCLUDED_ARCHES="arm, i686"
TERMUX_PKG_RM_AFTER_INSTALL="
build-scripts
cmake
"

termux_step_pre_configure() {
	if [[ "$TERMUX_ON_DEVICE_BUILD" == "false" ]]; then
		termux_error_exit "This package is extremely hard to cross-compile. If you know how, please help!"
	fi
}

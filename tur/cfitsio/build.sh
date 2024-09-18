TERMUX_PKG_HOMEPAGE=https://heasarc.gsfc.nasa.gov/fitsio/
TERMUX_PKG_DESCRIPTION="a library of C and Fortran subroutines for reading and writing data files in FITS (Flexible Image Transport System) data format"
TERMUX_PKG_LICENSE="custom"
TERMUX_PKG_LICENSE_FILE="License.txt"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="4.3.1"
TERMUX_PKG_SRCURL=https://heasarc.gsfc.nasa.gov/FTP/software/fitsio/c/cfitsio-${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=47a7c8ee05687be1e1d8eeeb94fb88f060fbf3cd8a4df52ccb88d5eb0f5062be
TERMUX_PKG_DEPENDS="curl, zlib"
TERMUX_PKG_FORCE_CMAKE=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	LDFLAGS+=" -lm"

	if [ -e licenses/License.txt ]; then
		cp licenses/License.txt License.txt
	fi
}

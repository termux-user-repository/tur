TERMUX_PKG_HOMEPAGE=https://heasarc.gsfc.nasa.gov/fitsio/
TERMUX_PKG_DESCRIPTION="a library of C and Fortran subroutines for reading and writing data files in FITS (Flexible Image Transport System) data format"
TERMUX_PKG_LICENSE="custom"
TERMUX_PKG_LICENSE_FILE="License.txt"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="4.5.0"
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=https://heasarc.gsfc.nasa.gov/FTP/software/fitsio/c/cfitsio-${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=e4854fc3365c1462e493aa586bfaa2f3d0bb8c20b75a524955db64c27427ce09
TERMUX_PKG_DEPENDS="curl, zlib"
TERMUX_PKG_FORCE_CMAKE=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	LDFLAGS+=" -lm"

	if [ -e licenses/License.txt ]; then
		cp licenses/License.txt License.txt
	fi
}

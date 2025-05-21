TERMUX_PKG_HOMEPAGE=https://heasarc.gsfc.nasa.gov/fitsio/
TERMUX_PKG_DESCRIPTION="a library of C and Fortran subroutines for reading and writing data files in FITS (Flexible Image Transport System) data format"
TERMUX_PKG_LICENSE="custom"
TERMUX_PKG_LICENSE_FILE="License.txt"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="4.5.0"
TERMUX_PKG_REVISION=2
TERMUX_PKG_SRCURL="https://github.com/HEASARC/cfitsio/archive/refs/tags/cfitsio-$TERMUX_PKG_VERSION.tar.gz"
TERMUX_PKG_SHA256=93db9e519efe372657d97e96e68c888aa65696b0ee31408780efa6388563989b
TERMUX_PKG_DEPENDS="curl, zlib"
TERMUX_PKG_FORCE_CMAKE=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_METHOD=repology
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DCMAKE_SYSTEM_NAME=Linux
-DM_LIB=
"

termux_step_pre_configure() {
	LDFLAGS+=" -lm"

	if [ -e licenses/License.txt ]; then
		cp licenses/License.txt License.txt
	fi
}

termux_step_post_massage() {
	# Do not forget to bump revision of reverse dependencies and rebuild them
	# after SOVERSION is changed.
	local _SOVERSION_GUARD_FILES="
lib/libcfitsio.so.10
"
	local f
	for f in ${_SOVERSION_GUARD_FILES}; do
		if [ ! -e "${f}" ]; then
			termux_error_exit "SOVERSION guard check failed."
		fi
	done
}

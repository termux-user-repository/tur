TERMUX_PKG_HOMEPAGE=https://wiki.documentfoundation.org/DLP/Libraries/libetonyek
TERMUX_PKG_DESCRIPTION="CorelDraw file format importer library for LibreOffice"
TERMUX_PKG_LICENSE="MPL-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=0.1.10
TERMUX_PKG_SRCURL=https://dev-www.libreoffice.org/src/libetonyek/libetonyek-${TERMUX_PKG_VERSION}.tar.xz
TERMUX_PKG_SHA256=b430435a6e8487888b761dc848b7981626eb814884963ffe25eb26a139301e9a
TERMUX_PKG_DEPENDS="libxml2, libwpd, librevenge, liblangtag, zlib"
TERMUX_PKG_BUILD_DEPENDS="boost, cppunit, glm, mdds"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="--with-mdds=2.1"

termux_step_pre_configure() {
	local _libgcc_file="$($CC -print-libgcc-file-name)"
	local _libgcc_path="$(dirname $_libgcc_file)"
	local _libgcc_name="$(basename $_libgcc_file)"
	LDFLAGS+=" -L$_libgcc_path -l:$_libgcc_name"
}

termux_step_post_massage() {
	# Do not forget to bump revision of reverse dependencies and rebuild them
	# after SOVERSION is changed.
	local _SOVERSION_GUARD_FILES="
lib/libetonyek-0.1.so
"
	local f
	for f in ${_SOVERSION_GUARD_FILES}; do
		if [ ! -e "${f}" ]; then
			termux_error_exit "SOVERSION guard check failed."
		fi
	done
}

TERMUX_PKG_HOMEPAGE=https://wiki.documentfoundation.org/DLP/Libraries/libvisio
TERMUX_PKG_DESCRIPTION="Library providing ability to interpret and import visio diagrams"
TERMUX_PKG_LICENSE="MPL-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=0.1.7
TERMUX_PKG_SRCURL=https://dev-www.libreoffice.org/src/libvisio/libvisio-${TERMUX_PKG_VERSION}.tar.xz
TERMUX_PKG_SHA256=8faf8df870cb27b09a787a1959d6c646faa44d0d8ab151883df408b7166bea4c
TERMUX_PKG_DEPENDS="libxml2, libicu, librevenge"
TERMUX_PKG_BUILD_DEPENDS="boost, cppunit"

termux_step_pre_configure() {
	local _libgcc_file="$($CC -print-libgcc-file-name)"
	local _libgcc_path="$(dirname $_libgcc_file)"
	local _libgcc_name="$(basename $_libgcc_file)"
	LDFLAGS+=" -L$_libgcc_path -l:$_libgcc_name"
}

termux_step_post_configure() {
	# Avoid overlinking
	sed -i 's/ -shared / -Wl,--as-needed\0/g' ./libtool
}

termux_step_post_massage() {
	# Do not forget to bump revision of reverse dependencies and rebuild them
	# after SOVERSION is changed.
	local _SOVERSION_GUARD_FILES="
lib/libvisio-0.1.so
"
	local f
	for f in ${_SOVERSION_GUARD_FILES}; do
		if [ ! -e "${f}" ]; then
			termux_error_exit "SOVERSION guard check failed."
		fi
	done
}

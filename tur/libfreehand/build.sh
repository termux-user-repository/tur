TERMUX_PKG_HOMEPAGE="https://wiki.documentfoundation.org/DLP/Libraries/libfreehand"
TERMUX_PKG_DESCRIPTION="a library for import of Aldus/Macromedia/Adobe FreeHand documents"
TERMUX_PKG_LICENSE="MPL-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=0.1.2
TERMUX_PKG_SRCURL="https://dev-www.libreoffice.org/src/libfreehand/libfreehand-${TERMUX_PKG_VERSION}.tar.xz"
TERMUX_PKG_SHA256=0e422d1564a6dbf22a9af598535425271e583514c0f7ba7d9091676420de34ac
TERMUX_PKG_DEPENDS="boost, littlecms, libicu, librevenge, zlib"
TERMUX_PKG_BUILD_DEPENDS="boost-headers, gperf"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--disable-tests
--disable-werror
"

termux_step_post_configure() {
	# Avoid overlinking
	sed -i 's/ -shared / -Wl,--as-needed\0/g' ./libtool
}

termux_step_post_massage() {
	# Do not forget to bump revision of reverse dependencies and rebuild them
	# after SOVERSION is changed.
	local _SOVERSION_GUARD_FILES="
lib/libfreehand-0.1.so
"
	local f
	for f in ${_SOVERSION_GUARD_FILES}; do
		if [ ! -e "${f}" ]; then
			termux_error_exit "SOVERSION guard check failed."
		fi
	done
}

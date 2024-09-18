TERMUX_PKG_HOMEPAGE="https://gitlab.com/orcus/orcus/"
TERMUX_PKG_DESCRIPTION="File import filter library for spreadsheet documents."
TERMUX_PKG_LICENSE="MPL-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=0.19.2
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=https://gitlab.com/orcus/orcus/-/archive/${TERMUX_PKG_VERSION}/orcus-${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=4fb632224aecc29e79c432f862c446b32f97b81d6855fa3773a2f11eda3d1c3b
TERMUX_PKG_DEPENDS="boost, libc++, libixion, zlib"
TERMUX_PKG_BUILD_DEPENDS="boost-headers, mdds"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--disable-python
"

termux_step_pre_configure() {
	NOCONFIGURE=1 ./autogen.sh

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
lib/liborcus-0.18.so
lib/liborcus-parser-0.18.so
lib/liborcus-spreadsheet-model-0.18.so
"
	local f
	for f in ${_SOVERSION_GUARD_FILES}; do
		if [ ! -e "${f}" ]; then
			termux_error_exit "SOVERSION guard check failed."
		fi
	done
}

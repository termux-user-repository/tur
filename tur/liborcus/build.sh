TERMUX_PKG_HOMEPAGE="https://gitlab.com/orcus/orcus/"
TERMUX_PKG_DESCRIPTION="File import filter library for spreadsheet documents."
TERMUX_PKG_LICENSE="MPL-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=0.19.2
TERMUX_PKG_SRCURL=https://gitlab.com/orcus/orcus/-/archive/${TERMUX_PKG_VERSION}/orcus-${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=4fb632224aecc29e79c432f862c446b32f97b81d6855fa3773a2f11eda3d1c3b
TERMUX_PKG_DEPENDS="boost, libixion, python, zlib"
TERMUX_PKG_BUILD_DEPENDS="boost-headers, mdds"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DMDDS_INCLUDEDIR=$TERMUX_PREFIX/include/mdds-2.1
-DIXION_INCLUDEDIR=$TERMUX_PREFIX/include/ixion-0.18
"

termux_step_pre_configure() {
	LDFLAGS+=" -lboost_filesystem -lboost_system -lboost_program_options"
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

TERMUX_PKG_HOMEPAGE=https://github.com/FreeSpacenav/libspnav
TERMUX_PKG_DESCRIPTION="Library for communicating with spacenavd or 3dxsrv to get input from 6-dof devices"
TERMUX_PKG_LICENSE="BSD 3-Clause"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=1.2
TERMUX_PKG_SRCURL=https://github.com/FreeSpacenav/libspnav/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=e675a2476bd407b8d97a33f93c6651ad3ecdfd422916f260bd620f2aec7ca45f
TERMUX_PKG_DEPENDS="libx11"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	LDFLAGS+=" -lm"
}

termux_step_post_massage() {
	# Do not forget to bump revision of reverse dependencies and rebuild them
	# after SOVERSION is changed.
	local _SOVERSION_GUARD_FILES="
lib/libspnav.so.0
"
	local f
	for f in ${_SOVERSION_GUARD_FILES}; do
		if [ ! -e "${f}" ]; then
			termux_error_exit "SOVERSION guard check failed."
		fi
	done
}

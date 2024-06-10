TERMUX_PKG_HOMEPAGE=https://github.com/opencollab/arpack-ng
TERMUX_PKG_DESCRIPTION="Collection of Fortran77 subroutines designed to solve large scale eigenvalue problems."
TERMUX_PKG_LICENSE="BSD"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=1:3.9.0
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=https://github.com/opencollab/arpack-ng/archive/refs/tags/${TERMUX_PKG_VERSION#*:}.tar.gz
TERMUX_PKG_SHA256=24f2a2b259992d3c797d80f626878aa8e2ed5009d549dad57854bbcfb95e1ed0
TERMUX_PKG_DEPENDS="libopenblas"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DCMAKE_SYSTEM_NAME=Linux
"

source $TERMUX_SCRIPTDIR/common-files/setup_toolchain_gcc.sh

termux_step_pre_configure() {
	_setup_toolchain_ndk_gcc_11
	_override_configure_cmake_for_gcc
}

termux_step_post_massage() {
	# Do not forget to bump revision of reverse dependencies and rebuild them
	# after SOVERSION is changed.
	local _SOVERSION_GUARD_FILES="
lib/libarpack.so.2
"
	local f
	for f in ${_SOVERSION_GUARD_FILES}; do
		if [ ! -e "${f}" ]; then
			termux_error_exit "SOVERSION guard check failed."
		fi
	done
}

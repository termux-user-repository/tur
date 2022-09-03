TERMUX_PKG_HOMEPAGE=http://www.openblas.net/
TERMUX_PKG_DESCRIPTION="An optimized BLAS library"
TERMUX_PKG_LICENSE="BSD 3-Clause"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=0.3.21
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=https://github.com/xianyi/OpenBLAS.git
TERMUX_PKG_PROVIDES="libopenblas"
TERMUX_PKG_REPLACES="libopenblas"
TERMUX_PKG_CONFLICTS="libopenblas"
TERMUX_PKG_FORCE_CMAKE=true
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="-DBUILD_SHARED_LIBS=ON -DBUILD_STATIC_LIBS=OFF"

source $TERMUX_SCRIPTDIR/common-files/setup_toolchain_ndk_r17c.sh
source $TERMUX_SCRIPTDIR/common-files/setup_cmake_with_gcc.sh

termux_step_pre_configure() {
	if $TERMUX_ON_DEVICE_BUILD; then
		termux_error_exit "Package '$TERMUX_PKG_NAME' is not available for on-device builds."
	fi

	_setup_toolchain_ndk_r17c_gcc_11
	_override_configure_cmake_for_gcc

	if [ "$TERMUX_ARCH" == "x86_64" ] || [ "$TERMUX_ARCH" == "i686" ]; then
		# XXX: CORE2 seems too old. So which target should be set for openblas?
		TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" -DTARGET=CORE2"
	fi
}

TERMUX_PKG_HOMEPAGE=https://github.com/mpimd-csc/qrupdate-ng
TERMUX_PKG_DESCRIPTION="A Library for Fast Updating of QR and Cholesky Decompositions."
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=1.1.5
TERMUX_PKG_SRCURL=https://github.com/mpimd-csc/qrupdate-ng/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=912426f7cb9436bb3490c3102a64d9a2c3883d700268a26d4d738b7607903757
TERMUX_PKG_DEPENDS="libopenblas"

source $TERMUX_SCRIPTDIR/common-files/setup_toolchain_gcc.sh

termux_step_pre_configure() {
	_setup_toolchain_ndk_gcc_11
	_override_configure_cmake_for_gcc
}

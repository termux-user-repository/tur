TERMUX_PKG_HOMEPAGE=https://computing.llnl.gov/projects/sundials
TERMUX_PKG_DESCRIPTION="SUite of Nonlinear and DIfferential/ALgebraic equation Solvers."
TERMUX_PKG_LICENSE="BSD 3-Clause"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=6.5.1
TERMUX_PKG_SRCURL=https://github.com/LLNL/sundials/releases/download/v${TERMUX_PKG_VERSION}/sundials-${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=4252303805171e4dbdd19a01e52c1dcfe0dafc599c3cfedb0a5c2ffb045a8a75
TERMUX_PKG_DEPENDS="libopenblas, suitesparse"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DBUILD_ARKODE=ON
-DBUILD_CVODE=ON
-DBUILD_CVODES=ON
-DBUILD_IDA=ON
-DBUILD_IDAS=ON
-DBUILD_KINSOL=ON
-DBUILD_SHARED_LIBS=ON
-DBUILD_STATIC_LIBS=ON
-DBUILD_FORTRAN_MODULE_INTERFACE=OFF
-DENABLE_KLU=ON
-DKLU_INCLUDE_DIR=$TERMUX_PREFIX/include
-DKLU_LIBRARY_DIR=$TERMUX_PREFIX/lib
-DENABLE_OPENMP=ON
-DENABLE_PTHREAD=ON
"
TERMUX_PKG_RM_AFTER_INSTALL="examples/"

source $TERMUX_SCRIPTDIR/common-files/setup_toolchain_gcc.sh

termux_step_pre_configure() {
	_setup_toolchain_ndk_gcc_11
	_override_configure_cmake_for_gcc
}

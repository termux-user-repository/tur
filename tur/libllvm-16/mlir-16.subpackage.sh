TERMUX_SUBPKG_INCLUDE="
$_INSTALL_PREFIX_R/bin/mlir-*
$_INSTALL_PREFIX_R/include/mlir*
$_INSTALL_PREFIX_R/lib/cmake/mlir/
$_INSTALL_PREFIX_R/lib/libMLIR.so
$_INSTALL_PREFIX_R/lib/libmlir*so
"
TERMUX_SUBPKG_DESCRIPTION="A Multi-Level Intermediate Representation for compilers from LLVM"
TERMUX_SUBPKG_DEPENDS="libc++, ncurses"

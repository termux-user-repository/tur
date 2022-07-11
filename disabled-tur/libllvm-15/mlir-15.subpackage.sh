TERMUX_SUBPKG_INCLUDE="
$_INSTALL_PREFIX/bin/mlir-*
$_INSTALL_PREFIX/include/mlir*
$_INSTALL_PREFIX/lib/cmake/mlir/
$_INSTALL_PREFIX/lib/libMLIR.so
$_INSTALL_PREFIX/lib/libmlir*so
"
TERMUX_SUBPKG_DESCRIPTION="A Multi-Level Intermediate Representation for compilers from LLVM"
TERMUX_SUBPKG_DEPENDS="libc++, ncurses"

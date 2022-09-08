TERMUX_SUBPKG_INCLUDE="
bin/flang*
$_INSTALL_PREFIX/bin/flang*
$_INSTALL_PREFIX/bin/*cpp
$_INSTALL_PREFIX/include/flang*
$_INSTALL_PREFIX/lib/libflang*
$_INSTALL_PREFIX/lib/libFortran*
$_INSTALL_PREFIX/lib/cmake/flang
"
TERMUX_SUBPKG_DESCRIPTION="Fortran language frontend for LLVM"
TERMUX_SUBPKG_DEPENDS="clang-16, lld-16, llvm-16, mlir-16"

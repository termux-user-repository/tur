TERMUX_SUBPKG_INCLUDE="
$_INSTALL_PREFIX/bin/FileCheck
$_INSTALL_PREFIX/bin/count
$_INSTALL_PREFIX/bin/lli-child-target
$_INSTALL_PREFIX/bin/llvm-PerfectShuffle
$_INSTALL_PREFIX/bin/llvm-jitlink-executor
$_INSTALL_PREFIX/bin/not
$_INSTALL_PREFIX/bin/obj2yaml
$_INSTALL_PREFIX/bin/yaml2obj
$_INSTALL_PREFIX/bin/yaml-bench
$_INSTALL_PREFIX/share/man/man1/FileCheck.1.gz
"
TERMUX_SUBPKG_DESCRIPTION="LLVM Development Tools"
TERMUX_SUBPKG_DEPENDS="libc++, ncurses, zlib"

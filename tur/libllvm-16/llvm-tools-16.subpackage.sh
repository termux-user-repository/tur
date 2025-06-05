TERMUX_SUBPKG_INCLUDE="
$_INSTALL_PREFIX_R/bin/FileCheck
$_INSTALL_PREFIX_R/bin/count
$_INSTALL_PREFIX_R/bin/lli-child-target
$_INSTALL_PREFIX_R/bin/llvm-PerfectShuffle
$_INSTALL_PREFIX_R/bin/llvm-jitlink-executor
$_INSTALL_PREFIX_R/bin/not
$_INSTALL_PREFIX_R/bin/obj2yaml
$_INSTALL_PREFIX_R/bin/yaml2obj
$_INSTALL_PREFIX_R/bin/yaml-bench
$_INSTALL_PREFIX_R/share/man/man1/FileCheck.1.gz
"
TERMUX_SUBPKG_DESCRIPTION="LLVM Development Tools"
TERMUX_SUBPKG_DEPENDS="libc++, ncurses, zlib"

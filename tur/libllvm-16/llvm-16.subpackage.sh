TERMUX_SUBPKG_INCLUDE="
$_INSTALL_PREFIX/bin/bugpoint
$_INSTALL_PREFIX/bin/dsymutil
$_INSTALL_PREFIX/bin/llc
$_INSTALL_PREFIX/bin/lli
$_INSTALL_PREFIX/bin/llvm*
$_INSTALL_PREFIX/bin/opt
$_INSTALL_PREFIX/bin/sancov
$_INSTALL_PREFIX/bin/sanstats
$_INSTALL_PREFIX/bin/split-file
$_INSTALL_PREFIX/bin/verify-uselistorder
$_INSTALL_PREFIX/share/man/man1/bugpoint.1.gz
$_INSTALL_PREFIX/share/man/man1/dsymutil.1.gz
$_INSTALL_PREFIX/share/man/man1/llc.1.gz
$_INSTALL_PREFIX/share/man/man1/lli.1.gz
$_INSTALL_PREFIX/share/man/man1/llvm*
$_INSTALL_PREFIX/share/man/man1/opt.1.gz
$_INSTALL_PREFIX/share/man/man1/*tblgen.1.gz
$_INSTALL_PREFIX/share/opt-viewer
"
TERMUX_SUBPKG_DESCRIPTION="LLVM modular compiler and toolchain executables"
TERMUX_SUBPKG_BREAKS="libllvm (<< 11.0.0-1)"
TERMUX_SUBPKG_REPLACES="libllvm (<< 11.0.0-1)"

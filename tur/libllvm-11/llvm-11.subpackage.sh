TERMUX_SUBPKG_INCLUDE="
opt/libllvm-11/bin/bugpoint
opt/libllvm-11/bin/dsymutil
opt/libllvm-11/bin/llc
opt/libllvm-11/bin/lli
opt/libllvm-11/bin/llvm*
opt/libllvm-11/bin/obj2yaml
opt/libllvm-11/bin/opt
opt/libllvm-11/bin/sancov
opt/libllvm-11/bin/sanstats
opt/libllvm-11/bin/verify-uselistorder
opt/libllvm-11/bin/yaml2obj
share/opt-viewer
share/man/man1/llc.1.gz
share/man/man1/lli.1.gz
share/man/man1/llvm*
share/man/man1/opt.1.gz
share/man/man1/bugpoint.1.gz
share/man/man1/dsymutil.1.gz
share/man/man1/tblgen.1.gz
"
TERMUX_SUBPKG_DESCRIPTION="LLVM modular compiler and toolchain executables"
TERMUX_SUBPKG_BREAKS="libllvm (<< 11.0.0-1)"
TERMUX_SUBPKG_REPLACES="libllvm (<< 11.0.0-1)"

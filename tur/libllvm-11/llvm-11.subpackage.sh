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
opt/share/opt-viewer
"
TERMUX_SUBPKG_DESCRIPTION="LLVM modular compiler and toolchain executables"
TERMUX_SUBPKG_BREAKS="libllvm (<< 11.0.0-1)"
TERMUX_SUBPKG_REPLACES="libllvm (<< 11.0.0-1)"

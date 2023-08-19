TERMUX_SUBPKG_INCLUDE="
opt/libllvm-13/bin/bugpoint
opt/libllvm-13/bin/dsymutil
opt/libllvm-13/bin/llc
opt/libllvm-13/bin/lli
opt/libllvm-13/bin/llvm*
opt/libllvm-13/bin/obj2yaml
opt/libllvm-13/bin/opt
opt/libllvm-13/bin/sancov
opt/libllvm-13/bin/sanstats
opt/libllvm-13/bin/verify-uselistorder
opt/libllvm-13/bin/yaml2obj
opt/share/opt-viewer
"
TERMUX_SUBPKG_DESCRIPTION="LLVM modular compiler and toolchain executables"
TERMUX_SUBPKG_BREAKS="libllvm (<< 13.0.1-1)"
TERMUX_SUBPKG_REPLACES="libllvm (<< 13.0.1-1)"

TERMUX_SUBPKG_DESCRIPTION="A generic and open source machine emulator and virtualizer (headless)"
TERMUX_SUBPKG_DEPEND_ON_PARENT=deps
TERMUX_SUBPKG_BREAKS="qemu-system-ppc-headless, qemu-system-ppc"
TERMUX_SUBPKG_REPLACES="qemu-system-ppc-headless, qemu-system-ppc"
TERMUX_SUBPKG_PROVIDES="qemu-system-ppc-headless, qemu-system-ppc"
TERMUX_SUBPKG_INCLUDE="
bin/qemu-system-ppc
share/man/man1/qemu-system-ppc.1.gz
"

TERMUX_SUBPKG_DESCRIPTION="A generic and open source machine emulator and virtualizer (headless)"
TERMUX_SUBPKG_DEPEND_ON_PARENT=deps
TERMUX_SUBPKG_BREAKS="qemu-system-m68k-headless, qemu-system-m68k"
TERMUX_SUBPKG_REPLACES="qemu-system-m68k-headless, qemu-system-m68k"
TERMUX_SUBPKG_PROVIDES="qemu-system-m68k-headless, qemu-system-m68k"
TERMUX_SUBPKG_INCLUDE="
bin/qemu-system-m68k
share/man/man1/qemu-system-m68k.1.gz
"

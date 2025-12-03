TERMUX_SUBPKG_DESCRIPTION="A generic and open source machine emulator and virtualizer"
TERMUX_SUBPKG_DEPEND_ON_PARENT=deps
TERMUX_SUBPKG_CONFLICTS="qemu-system-riscv64-headless, qemu-system-riscv64"
TERMUX_SUBPKG_REPLACES="qemu-system-riscv64-headless, qemu-system-riscv64"
TERMUX_SUBPKG_PROVIDES="qemu-system-riscv64"
TERMUX_SUBPKG_INCLUDE="
bin/qemu-system-riscv64
share/man/man1/qemu-system-riscv64.1.gz
"

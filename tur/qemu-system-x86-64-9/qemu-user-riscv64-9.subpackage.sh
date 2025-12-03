TERMUX_SUBPKG_DESCRIPTION="QEMU Linux user mode emulator"
TERMUX_SUBPKG_DEPENDS="glib, libandroid-shmem, libdw, libgnutls, libpixman"
TERMUX_SUBPKG_DEPEND_ON_PARENT=false
TERMUX_SUBPKG_CONFLICTS="qemu-user-riscv64"
TERMUX_SUBPKG_REPLACES="qemu-user-riscv64"
TERMUX_SUBPKG_PROVIDES="qemu-user-riscv64"
TERMUX_SUBPKG_INCLUDE="bin/qemu-riscv64"

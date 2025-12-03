TERMUX_SUBPKG_DESCRIPTION="A generic and open source machine emulator and virtualizer"
TERMUX_SUBPKG_DEPEND_ON_PARENT=deps
TERMUX_SUBPKG_CONFLICTS="qemu-system-ppc64-headless, qemu-system-ppc64"
TERMUX_SUBPKG_REPLACES="qemu-system-ppc64-headless, qemu-system-ppc64"
TERMUX_SUBPKG_PROVIDES="qemu-system-ppc64"
TERMUX_SUBPKG_INCLUDE="
bin/qemu-system-ppc64
share/man/man1/qemu-system-ppc64.1.gz
"

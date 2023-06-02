TERMUX_PKG_HOMEPAGE=https://llvm.org/
TERMUX_PKG_DESCRIPTION="Modular compiler and toolchain technologies library (Version 16)"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_LICENSE_FILE="LICENSE.TXT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="20230603-16.0"
TERMUX_PKG_SKIP_SRC_EXTRACT=true
TERMUX_PKG_DEPENDS="binutils, libc++, libllvm, ncurses, ndk-sysroot, libffi, zlib"
TERMUX_PKG_PLATFORM_INDEPENDENT=true

_INSTALL_PREFIX_R="opt/libllvm-16"
_INSTALL_PREFIX="$TERMUX_PREFIX/$_INSTALL_PREFIX_R"

termux_step_make_install() {
	mkdir -p $_INSTALL_PREFIX
	touch $_INSTALL_PREFIX/.placeholder{,-{clang-16,libcompiler-rt-16,lld-16,llvm-16,llvm-tools-16,mlir-16}}
}

termux_step_install_license() {
	mkdir -p $TERMUX_PREFIX/share/doc/$TERMUX_PKG_NAME
	cp -f $TERMUX_PREFIX/share/doc/libllvm/LICENSE.TXT $TERMUX_PREFIX/share/doc/$TERMUX_PKG_NAME
}

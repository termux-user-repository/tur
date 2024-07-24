TERMUX_PKG_HOMEPAGE=https://github.com/flang-compiler/flang
TERMUX_PKG_DESCRIPTION="An out-of-tree Fortran compiler targeting LLVM"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_LICENSE_FILE="LICENSE.txt"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
_DATE=2023.05.20
TERMUX_PKG_VERSION=${_DATE//./}
_FLANG_COMMIT=5caea370cd46260de6f48fed72b34c79c5702378
TERMUX_PKG_SRCURL=https://github.com/flang-compiler/flang/archive/${_FLANG_COMMIT}.zip
TERMUX_PKG_SHA256=635b984acd554674cdbc6395567ff5c71d97710083aa1d9470a057105231387b
TERMUX_PKG_DEPENDS="libandroid-complex-math, libandroid-execinfo, libllvm-classic-flang"
TERMUX_PKG_BLACKLISTED_ARCHES="arm, i686"
TERMUX_PKG_NO_STATICSPLIT=true

_INSTALL_PREFIX_R="opt/classic-flang"
_INSTALL_PREFIX="$TERMUX_PREFIX/$_INSTALL_PREFIX_R"

TARGET_ARCH_TO_BUILD="X86"

if [ "$TERMUX_ARCH" == "aarch64" ]; then
	TARGET_ARCH_TO_BUILD="AArch64"
fi

TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DCMAKE_INSTALL_PREFIX=$_INSTALL_PREFIX
-DLLVM_CONFIG=$_INSTALL_PREFIX/bin/llvm-config
-DCMAKE_CXX_COMPILER=$_INSTALL_PREFIX/bin/clang++
-DCMAKE_C_COMPILER=$_INSTALL_PREFIX/bin/clang
-DCMAKE_Fortran_COMPILER=$_INSTALL_PREFIX/bin/flang
-DCMAKE_Fortran_COMPILER_ID=Flang
-DLLVM_TARGETS_TO_BUILD=$TARGET_ARCH_TO_BUILD
-DWITH_WERROR=OFF
"

termux_step_pre_configure() {
	if [ "${TERMUX_ON_DEVICE_BUILD}" = false ]; then
		termux_error_exit "This package doesn't support cross-compiling."
	fi

	# Build libpgmath
	pushd $TERMUX_PKG_SRCDIR/runtime/libpgmath
	mkdir -p build && cd build
	cmake -DCMAKE_INSTALL_PREFIX=$TERMUX_PREFIX ..
	make -j$TERMUX_PKG_MAKE_PROCESSES
	make install
	cd .. && rm -rf build
	popd

	mkdir -p $_INSTALL_PREFIX
}

termux_step_post_make_install() {
	for lib in libflang.so libflangrti.so libompstub.so; do
		ln -sfr $_INSTALL_PREFIX/lib/$lib $TERMUX_PREFIX/lib/$lib
	done
}

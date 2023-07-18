TERMUX_PKG_HOMEPAGE=https://clang.llvm.org/
TERMUX_PKG_DESCRIPTION="Modular compiler and toolchain technologies library (Version 15)"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_LICENSE_FILE="llvm/LICENSE.TXT"
TERMUX_PKG_MAINTAINER="@buttaface, @termux-user-repository"
TERMUX_PKG_VERSION=14.0.6
TERMUX_PKG_SHA256=8b3cfd7bc695bd6cea0f37f53f0981f34f87496e79e2529874fd03a2f9dd3a8a
TERMUX_PKG_SRCURL=https://github.com/llvm/llvm-project/releases/download/llvmorg-$TERMUX_PKG_VERSION/llvm-project-$TERMUX_PKG_VERSION.src.tar.xz
TERMUX_PKG_HOSTBUILD=true
TERMUX_PKG_DEPENDS="binutils, libc++, ncurses, ndk-sysroot, libffi, zlib"

# See http://llvm.org/docs/CMake.html:
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DANDROID_PLATFORM_LEVEL=$TERMUX_PKG_API_LEVEL
-DPYTHON_EXECUTABLE=$(command -v python3)
-DLLVM_ENABLE_PIC=ON
-DLLVM_ENABLE_LIBEDIT=OFF
-DLLVM_INCLUDE_TESTS=OFF
-DDEFAULT_SYSROOT=$(dirname $TERMUX_PREFIX)
-DLLVM_LINK_LLVM_DYLIB=ON
-DLLVM_TABLEGEN=$TERMUX_PKG_HOSTBUILD_DIR/bin/llvm-tblgen
-DLIBOMP_ENABLE_SHARED=FALSE
-DLLVM_ENABLE_SPHINX=ON
-DSPHINX_OUTPUT_MAN=ON
-DSPHINX_WARNINGS_AS_ERRORS=OFF
-DLLVM_TARGETS_TO_BUILD=all
-DPERL_EXECUTABLE=$(command -v perl)
-DLLVM_ENABLE_FFI=ON
-DLLVM_INSTALL_UTILS=ON
-DCMAKE_INSTALL_PREFIX=$TERMUX_PREFIX/opt/libllvm-14
"

if [ $TERMUX_ARCH_BITS = 32 ]; then
	# Do not set _FILE_OFFSET_BITS=64
	TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" -DLLVM_FORCE_SMALLFILE_FOR_ANDROID=on"
fi

TERMUX_PKG_FORCE_CMAKE=true
TERMUX_PKG_HAS_DEBUG=false

termux_step_host_build() {
	termux_setup_cmake
	termux_setup_ninja

	cmake -G Ninja -DCMAKE_BUILD_TYPE=Release $TERMUX_PKG_SRCDIR/llvm
	ninja -j $TERMUX_MAKE_PROCESSES llvm-tblgen
}

termux_step_pre_configure() {
	# Add unknown vendor, otherwise it screws with the default LLVM triple
	# detection.
	export LLVM_DEFAULT_TARGET_TRIPLE=${CCTERMUX_HOST_PLATFORM/-/-unknown-}
	export LLVM_TARGET_ARCH
	if [ $TERMUX_ARCH = "arm" ]; then
		LLVM_TARGET_ARCH=ARM
	elif [ $TERMUX_ARCH = "aarch64" ]; then
		LLVM_TARGET_ARCH=AArch64
	elif [ $TERMUX_ARCH = "i686" ] || [ $TERMUX_ARCH = "x86_64" ]; then
		LLVM_TARGET_ARCH=X86
	else
		termux_error_exit "Invalid arch: $TERMUX_ARCH"
	fi
	# see CMakeLists.txt and tools/clang/CMakeLists.txt
	TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" -DLLVM_TARGET_ARCH=$LLVM_TARGET_ARCH"
	TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" -DLLVM_HOST_TRIPLE=$LLVM_DEFAULT_TARGET_TRIPLE"
	export TERMUX_SRCDIR_SAVE=$TERMUX_PKG_SRCDIR
	TERMUX_PKG_SRCDIR=$TERMUX_PKG_SRCDIR/llvm
}

termux_step_post_configure() {
	TERMUX_PKG_SRCDIR=$TERMUX_SRCDIR_SAVE
}

termux_step_post_make_install() {
	ln -sfr $TERMUX_PREFIX/opt/libllvm-14/lib/libLLVM-14.so $TERMUX_PREFIX/lib/
}

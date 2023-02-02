TERMUX_PKG_HOMEPAGE=https://llvm.org/
TERMUX_PKG_DESCRIPTION="Modular compiler and toolchain technologies library (Version 16)"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_LICENSE_FILE="llvm/LICENSE.TXT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
_LLVM_MAJOR_VERSION=16.0
_LLVM_VERSION=$_LLVM_MAJOR_VERSION.0-rc1
TERMUX_PKG_VERSION="1:$_LLVM_VERSION"
TERMUX_PKG_SRCURL=https://github.com/llvm/llvm-project/releases/download/llvmorg-${_LLVM_VERSION}/llvm-project-${_LLVM_VERSION//-/}.src.tar.xz
TERMUX_PKG_SHA256=8399db003b223ce33e3d7a5ee9df8dc3574cedffa5d9be4783660643f8402900
TERMUX_PKG_HOSTBUILD=true
TERMUX_PKG_DEPENDS="binutils, libc++, ncurses, ndk-sysroot, libffi, zlib"

_INSTALL_PREFIX_R="opt/libllvm-16"
_INSTALL_PREFIX="$TERMUX_PREFIX/$_INSTALL_PREFIX_R"
# See http://llvm.org/docs/CMake.html:
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DCMAKE_BUILD_TYPE=MinSizeRel
-DANDROID_PLATFORM_LEVEL=$TERMUX_PKG_API_LEVEL
-DLLVM_ENABLE_PIC=ON
-DLLVM_ENABLE_PROJECTS=clang;compiler-rt;mlir;lld;openmp
-DLLVM_ENABLE_LIBEDIT=OFF
-DLLVM_INCLUDE_TESTS=OFF
-DLLVM_INCLUDE_EXAMPLES=OFF
-DLLVM_INCLUDE_BENCHMARKS=OFF
-DCLANG_DEFAULT_RTLIB=compiler-rt
-DCLANG_DEFAULT_CXX_STDLIB=libc++
-DCLANG_DEFAULT_LINKER=lld-16
-DCLANG_INCLUDE_TESTS=OFF
-DCLANG_TOOL_C_INDEX_TEST_BUILD=OFF
-DCOMPILER_RT_USE_BUILTINS_LIBRARY=ON
-DDEFAULT_SYSROOT=$(dirname $TERMUX_PREFIX)
-DLLVM_LINK_LLVM_DYLIB=ON
-DLLVM_NATIVE_TOOL_DIR=$TERMUX_PKG_HOSTBUILD_DIR/bin
-DCROSS_TOOLCHAIN_FLAGS_LLVM_NATIVE=\"-DLLVM_NATIVE_TOOL_DIR=$TERMUX_PKG_HOSTBUILD_DIR/bin\"
-DLIBOMP_ENABLE_SHARED=FALSE
-DOPENMP_ENABLE_LIBOMPTARGET=OFF
-DLLVM_ENABLE_SPHINX=ON
-DSPHINX_OUTPUT_MAN=ON
-DSPHINX_WARNINGS_AS_ERRORS=OFF
-DLLVM_TARGETS_TO_BUILD=X86;AArch64;ARM
-DPERL_EXECUTABLE=$(command -v perl)
-DLLVM_ENABLE_FFI=ON
-DLLVM_INSTALL_UTILS=ON
-DCMAKE_INSTALL_PREFIX=$_INSTALL_PREFIX
-DFLANG_DEFAULT_LINKER=lld-16
-DMLIR_INSTALL_AGGREGATE_OBJECTS=OFF
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

	cmake -G Ninja "-DCMAKE_BUILD_TYPE=Release" \
				   "-DLLVM_ENABLE_PROJECTS=clang;mlir" \
				   $TERMUX_PKG_SRCDIR/llvm
	ninja -j $TERMUX_MAKE_PROCESSES clang-tblgen llvm-tblgen \
						mlir-tblgen mlir-linalg-ods-yaml-gen
}

termux_step_pre_configure() {
	export PATH="$TERMUX_PKG_HOSTBUILD_DIR/bin:$PATH"
	# Add unknown vendor, otherwise it screws with the default LLVM triple detection.
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
	local _RPATH_FLAG="-Wl,-rpath=$TERMUX_PREFIX/lib"
	local _RPATH_FLAG_ADD="-Wl,-rpath='\$ORIGIN/../lib' -Wl,-rpath=$TERMUX_PREFIX/lib"
	LDFLAGS="${LDFLAGS/$_RPATH_FLAG/$_RPATH_FLAG_ADD $_RPATH_FLAG}"
	export TERMUX_SRCDIR_SAVE=$TERMUX_PKG_SRCDIR
	TERMUX_PKG_SRCDIR=$TERMUX_PKG_SRCDIR/llvm
}

termux_step_post_configure() {
	TERMUX_PKG_SRCDIR=$TERMUX_SRCDIR_SAVE
}

termux_step_post_make_install() {
	ln -sfr $_INSTALL_PREFIX/bin/clang-16 $TERMUX_PREFIX/bin/

	ln -sfr $_INSTALL_PREFIX/bin/lld $TERMUX_PREFIX/bin/lld-16
	ln -sfr $_INSTALL_PREFIX/bin/lld $_INSTALL_PREFIX/bin/lld-16
	ln -sfr $_INSTALL_PREFIX/bin/ld.lld $TERMUX_PREFIX/bin/ld.lld-16

	ln -sfr $_INSTALL_PREFIX/lib/libLLVM-16.so $TERMUX_PREFIX/lib/
	ln -sfr $_INSTALL_PREFIX/lib/libLLVM-16.0.0.so $TERMUX_PREFIX/lib/
}

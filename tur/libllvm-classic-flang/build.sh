TERMUX_PKG_HOMEPAGE=https://github.com/flang-compiler/classic-flang-llvm-project/
TERMUX_PKG_DESCRIPTION="Modular compiler and toolchain technologies library (Version 15, Classic Flang Fork)"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_LICENSE_FILE="llvm/LICENSE.TXT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
_DATE=2023.04.19
TERMUX_PKG_VERSION=${_DATE//./}
TERMUX_PKG_REVISION=3
_LLVM_COMMIT=cd736e11b188a8f6ff14041abd818ad86f36b9bb
TERMUX_PKG_SRCURL=https://github.com/flang-compiler/classic-flang-llvm-project/archive/${_LLVM_COMMIT}.zip
TERMUX_PKG_SHA256=6a5caa2ccfabf9492443c31762900fc7c945201d43b3a705f31d56256091b109
TERMUX_PKG_HOSTBUILD=true
TERMUX_PKG_DEPENDS="binutils-is-llvm, libc++, ncurses, ndk-sysroot, libffi, zlib"
TERMUX_PKG_SUGGESTS="libandroid-complex-math, classic-flang"
# XXX: We may add this package later I suppose.
TERMUX_PKG_PROVIDES="libllvm-15, clang-15, lld-15"
TERMUX_PKG_REPLACES="libllvm-15, clang-15, lld-15"
TERMUX_PKG_CONFLICTS="libllvm-15, clang-15, lld-15"

_INSTALL_PREFIX_R="opt/classic-flang"
_INSTALL_PREFIX="$TERMUX_PREFIX/$_INSTALL_PREFIX_R"
# See http://llvm.org/docs/CMake.html:
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DANDROID_PLATFORM_LEVEL=$TERMUX_PKG_API_LEVEL
-DPYTHON_EXECUTABLE=$(command -v python3)
-DLLVM_ENABLE_CLASSIC_FLANG=ON
-DLLVM_ENABLE_PIC=ON
-DLLVM_ENABLE_PROJECTS=clang;compiler-rt;lld;openmp
-DLLVM_ENABLE_LIBEDIT=OFF
-DLLVM_ENABLE_LIBXML2=OFF
-DLLVM_INCLUDE_TESTS=OFF
-DCLANG_DEFAULT_RTLIB=compiler-rt
-DCLANG_DEFAULT_CXX_STDLIB=libc++
-DCLANG_DEFAULT_LINKER=lld-15
-DCLANG_INCLUDE_TESTS=OFF
-DCLANG_TOOL_C_INDEX_TEST_BUILD=OFF
-DCOMPILER_RT_USE_BUILTINS_LIBRARY=ON
-DDEFAULT_SYSROOT=$(dirname $TERMUX_PREFIX)
-DLLVM_LINK_LLVM_DYLIB=ON
-DCLANG_TABLEGEN=$TERMUX_PKG_HOSTBUILD_DIR/bin/clang-tblgen
-DLLVM_TABLEGEN=$TERMUX_PKG_HOSTBUILD_DIR/bin/llvm-tblgen
-DLIBOMP_ENABLE_SHARED=FALSE
-DOPENMP_ENABLE_LIBOMPTARGET=OFF
-DLLVM_ENABLE_SPHINX=ON
-DSPHINX_OUTPUT_MAN=ON
-DSPHINX_WARNINGS_AS_ERRORS=OFF
-DLLVM_TARGETS_TO_BUILD=all
-DPERL_EXECUTABLE=$(command -v perl)
-DLLVM_ENABLE_FFI=ON
-DLLVM_INSTALL_UTILS=ON
-DCMAKE_INSTALL_PREFIX=$_INSTALL_PREFIX
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
					"-DLLVM_ENABLE_PROJECTS=clang" \
					$TERMUX_PKG_SRCDIR/llvm
	ninja -j $TERMUX_PKG_MAKE_PROCESSES llvm-tblgen clang-tblgen
}

termux_step_pre_configure() {
	# Add unknown vendor, otherwise it screws with the default LLVM triple
	# detection.
	export LLVM_DEFAULT_TARGET_TRIPLE=${CCTERMUX_HOST_PLATFORM/-/-unknown-}
	export LLVM_TARGET_ARCH
	if [ $TERMUX_ARCH = "arm" ]; then
		LLVM_TARGET_ARCH=ARM
		CFLAGS=${CFLAGS//-mthumb /}
		CXXFLAGS=${CXXFLAGS//-mthumb /}
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
	_RPATH_FLAG="-Wl,-rpath=$TERMUX_PREFIX/lib"
	_RPATH_FLAG_ADD="-Wl,-rpath='\$ORIGIN/../lib' -Wl,-rpath=$TERMUX_PREFIX/lib"
	LDFLAGS="${LDFLAGS/$_RPATH_FLAG/$_RPATH_FLAG_ADD $_RPATH_FLAG}"
	echo $LDFLAGS
	export TERMUX_SRCDIR_SAVE=$TERMUX_PKG_SRCDIR
	TERMUX_PKG_SRCDIR=$TERMUX_PKG_SRCDIR/llvm
}

termux_step_post_configure() {
	TERMUX_PKG_SRCDIR=$TERMUX_SRCDIR_SAVE
}

termux_step_post_make_install() {
	ln -sfr $_INSTALL_PREFIX/bin/flang $TERMUX_PREFIX/bin/
	ln -sfr $_INSTALL_PREFIX/bin/clang-15 $TERMUX_PREFIX/bin/
	ln -sfr $_INSTALL_PREFIX/bin/lld $_INSTALL_PREFIX/bin/lld-15
	ln -sfr $_INSTALL_PREFIX/bin/lld $TERMUX_PREFIX/bin/lld-15
	ln -sfr $_INSTALL_PREFIX/bin/ld.lld $TERMUX_PREFIX/bin/ld.lld-15
	ln -sfr $_INSTALL_PREFIX/lib/libLLVM-15.so $TERMUX_PREFIX/lib/
}

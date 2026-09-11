TERMUX_PKG_HOMEPAGE=https://julialang.org/
TERMUX_PKG_DESCRIPTION="High-level, high-performance dynamic language for technical computing"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=1.10.12
TERMUX_PKG_SRCURL=https://github.com/JuliaLang/julia/releases/download/v${TERMUX_PKG_VERSION}/julia-${TERMUX_PKG_VERSION}-full.tar.gz
TERMUX_PKG_SHA256=28815e9c83f23167e53bd4a79c085e6b9547ae2808acb23415ab5c558a85ceec
TERMUX_PKG_AUTO_UPDATE=false
TERMUX_PKG_DEPENDS="clang, libcurl, libgit2, libgmp, libmpfr, libnghttp2, libopenblas, libssh2, mbedtls, pcre2, suitesparse, utf8proc, zlib"
TERMUX_PKG_BUILD_DEPENDS="7zip, cmake, ninja, perl, python, tar, which"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_UNDEF_SYMBOLS_FILES="all"

termux_step_pre_configure() {
	if [ "${TERMUX_ON_DEVICE_BUILD}" = false ]; then
		termux_error_exit "This package doesn't support cross-compiling."
	fi

	termux_setup_cmake
	termux_setup_ninja

	local _march=""
	local _cpu_target="generic"
	if [ "$TERMUX_ARCH" = "aarch64" ]; then
		_cpu_target="generic;cortex-a57;thunderx2t99;armv8.2-a,crypto;cortex-a76"
	elif [ "$TERMUX_ARCH" = "x86_64" ]; then
		_cpu_target="generic;sandybridge,-xsaveopt,clone_all;haswell,-rdrnd,clone_all;skylake;avx512"
	elif [ "$TERMUX_ARCH" = "arm" ]; then
		_cpu_target="armv7-a,neon;armv7-a,neon,vfp4"
	elif [ "$TERMUX_ARCH" = "i686" ]; then
		_march="pentium4"
		_cpu_target="pentium4;core2"
	fi

	cat <<- EOF > Make.user
		ARCH = ${TERMUX_ARCH}
		MARCH = ${_march}
		JULIA_CPU_TARGET = ${_cpu_target}
		OS = Linux
		CMAKE_GENERATOR = Ninja
		USECLANG = 1
		USE_SYSTEM_BLAS = 1
		USE_SYSTEM_LAPACK = 1
		override USE_BLAS64 = 0
		LIBBLASNAME = libopenblas
		LIBLAPACKNAME = libopenblas
		USE_INTEL_JITEVENTS = 0
		USE_PERF_JITEVENTS = 0
		USE_OPROFILE_JITEVENTS = 0
		WITH_ITTAPI = 0
		USE_SYSTEM_LIBSUITESPARSE = 1
		USE_SYSTEM_LIBGIT2 = 1
		USE_SYSTEM_MBEDTLS = 1
		USE_SYSTEM_LIBSSH2 = 1
		USE_SYSTEM_NGHTTP2 = 1
		USE_SYSTEM_CURL = 1
		USE_SYSTEM_GMP = 1
		USE_SYSTEM_MPFR = 1
		USE_SYSTEM_PCRE = 1
		USE_SYSTEM_UTF8PROC = 1
		USE_SYSTEM_ZLIB = 1
		USE_SYSTEM_P7ZIP = 1
		USE_SYSTEM_LIBUV = 0
		USE_SYSTEM_LIBUNWIND = 0
		USE_SYSTEM_DSFMT = 0
		USE_SYSTEM_LIBBLASTRAMPOLINE = 0
		USE_SYSTEM_OPENLIBM = 0
		USE_SYSTEM_LLVM = 0
		USE_SYSTEM_CSL = 1
		DISABLE_CSL = 1
		USE_BINARYBUILDER = 0
		JULIA_PRECOMPILE = 0
		LDFLAGS += -Wl,--undefined-version
		OSLIBS += \$(shell \$(CC) -print-libgcc-file-name)
		SHELL := ${TERMUX_PREFIX}/bin/sh
	EOF
}

termux_step_make() {
	unset MAKEFLAGS
	make -j"${TERMUX_PKG_MAKE_PROCESSES}" prefix="${TERMUX_PREFIX}"
}

termux_step_make_install() {
	unset MAKEFLAGS
	make install prefix="${TERMUX_PREFIX}"
}

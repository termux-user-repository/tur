TERMUX_PKG_HOMEPAGE=https://github.com/anomalyco/opentui
TERMUX_PKG_DESCRIPTION="High-performance terminal user interface library"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_LICENSE_FILE="LICENSE"
TERMUX_PKG_MAINTAINER="ULTRAXAS <contact@ultraxas.com>"
TERMUX_PKG_VERSION="0.4.3"
TERMUX_PKG_SRCURL="https://github.com/anomalyco/opentui/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=3a72427d6cc6c7dc1086d44037d4f4c499ebc38c2e3e67ecf998695e65c8337a
TERMUX_PKG_EXCLUDED_ARCHES="arm, i686"
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_pre_configure() {
	TERMUX_ZIG_VERSION="0.15.2"
	termux_setup_zig

	# NDK flags must not leak into zig
	unset CFLAGS CXXFLAGS CPPFLAGS LDFLAGS

	export ZIG_GLOBAL_CACHE_DIR="${TERMUX_PKG_BUILDDIR}/.zig-global-cache"

	(cd packages/core/src/zig && zig build --fetch)
}

termux_step_configure() {
	:
}

termux_step_make() {
	local _sysroot="${NDK}/toolchains/llvm/prebuilt/linux-x86_64/sysroot"
	local _libc_file="${TERMUX_PKG_TMPDIR}/zig-libc.txt"
	cat > "${_libc_file}" <<-EOF
		include_dir=${_sysroot}/usr/include
		sys_include_dir=${_sysroot}/usr/include/${TERMUX_HOST_PLATFORM}
		crt_dir=${_sysroot}/usr/lib/${TERMUX_HOST_PLATFORM}/${TERMUX_PKG_API_LEVEL}
		msvc_lib_dir=
		kernel32_lib_dir=
		gcc_dir=
	EOF

	cd packages/core/src/zig
	zig build \
		--libc "${_libc_file}" \
		-Dtarget="${TERMUX_ARCH}-linux-android.${TERMUX_PKG_API_LEVEL}" \
		-Doptimize=ReleaseFast
}

termux_step_make_install() {
	install -Dm755 -t "${TERMUX_PREFIX}/lib" \
		packages/core/src/zig/lib/${TERMUX_ARCH}-linux-android.${TERMUX_PKG_API_LEVEL}/libopentui.so

	sed \
		-e "s|@PREFIX@|${TERMUX_PREFIX}|g" \
		-e "s|@VERSION@|${TERMUX_PKG_VERSION}|g" \
		opentui.pc.in > opentui.pc
	install -Dm644 -t "${TERMUX_PREFIX}/lib/pkgconfig" opentui.pc
}

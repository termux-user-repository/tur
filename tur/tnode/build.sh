TERMUX_PKG_HOMEPAGE="https://github.com/Irithell/tnode"
TERMUX_PKG_DESCRIPTION="POSIX compatibility shim for Android SDCARD filesystem — LD_PRELOAD bridge for Node.js, Python, Ruby, C and C++ runtimes in Termux"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="Irithell <@Irithell>"
TERMUX_PKG_VERSION="0.1.3"
TERMUX_PKG_SKIP_SRC_EXTRACT=true
TERMUX_PKG_PLATFORM_INDEPENDENT=false

termux_step_make_install() {
	local arch
	case "$TERMUX_ARCH" in
		aarch64) arch="aarch64" ;;
		x86_64)  arch="x86_64"  ;;
		*)
			termux_error_exit "unsupported architecture: $TERMUX_ARCH"
			;;
	esac

	local base_url="https://github.com/Irithell/tnode/releases/download/v${TERMUX_PKG_VERSION}"
	local binary_asset="tnode-${arch}-android"
	local lib_asset="libthook-${arch}-android.so"
	local checksum_file="${TERMUX_PKG_CACHEDIR}/checksums.sha256"

	# download checksums
	termux_download \
		"${base_url}/checksums.sha256" \
		"$checksum_file" \
		SKIP_CHECKSUM

	# download and verify tnode binary
	local binary_sha256
	binary_sha256="$(grep "^[a-f0-9]*  ${binary_asset}$" "$checksum_file" | awk '{print $1}')"
	if [[ -z "$binary_sha256" ]]; then
		termux_error_exit "checksum not found for ${binary_asset}"
	fi

	termux_download \
		"${base_url}/${binary_asset}" \
		"${TERMUX_PKG_CACHEDIR}/${binary_asset}" \
		"$binary_sha256"

	# download and verify libthook.so
	local lib_sha256
	lib_sha256="$(grep "^[a-f0-9]*  ${lib_asset}$" "$checksum_file" | awk '{print $1}')"
	if [[ -z "$lib_sha256" ]]; then
		termux_error_exit "checksum not found for ${lib_asset}"
	fi

	termux_download \
		"${base_url}/${lib_asset}" \
		"${TERMUX_PKG_CACHEDIR}/${lib_asset}" \
		"$lib_sha256"

	# install
	install -Dm755 "${TERMUX_PKG_CACHEDIR}/${binary_asset}" \
		"${TERMUX_PREFIX}/bin/tnode"

	install -Dm644 "${TERMUX_PKG_CACHEDIR}/${lib_asset}" \
		"${TERMUX_PREFIX}/lib/libthook.so"
}

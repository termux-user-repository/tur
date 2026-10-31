# Common auto-update logic for GCC packages (gcc-N).
#
# Usage in build.sh:
#
# 	source "$TERMUX_SCRIPTDIR/common-files/package-update-scripts/gcc.sh"
#
# 	termux_pkg_auto_update() {
# 		tur_pkg_update_gcc "${TERMUX_PKG_VERSION%%.*}"
# 	}
#
# Requires: curl, jq (from termux-packages scripts environment).

tur_pkg_update_gcc() {
	local major="$1"
	local latest
	latest="$(
		curl --fail --silent --location --retry 3 \
			"https://mirrors.kernel.org/gnu/gcc/" |
			grep -oE "gcc-${major}\\.[0-9]+\\.0/" |
			sed -E 's|^gcc-||; s|/$||' |
			sort -V |
			tail -n1
	)" || termux_error_exit "failed to query GCC releases from mirrors.kernel.org"
	if [[ -z "${latest}" ]]; then
		termux_error_exit "failed to find latest GCC ${major} release"
	fi

	local prebuilt_json="$TERMUX_SCRIPTDIR/common-files/toolchain/prebuilt-gcc.json"
	local prebuilt_version
	prebuilt_version="$(jq -r --arg major "$major" '.[$major].version // empty' "$prebuilt_json")"
	if [[ "${prebuilt_version}" != "${latest}" ]]; then
		termux_error_exit "prebuilt GCC ${major} toolchain ${latest} is not in common-files/prebuilt-gcc.json (found: ${prebuilt_version:-none})"
	fi
	termux_pkg_upgrade_version "${latest}"
}

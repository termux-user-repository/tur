# Common auto-update logic for Node.js packages (nodejs-N).
#
# Usage in build.sh:
#
# 	source "$TERMUX_SCRIPTDIR/common-files/package-update-scripts/nodejs.sh"
#
# 	termux_pkg_auto_update() {
# 		tur_pkg_update_nodejs "${TERMUX_PKG_VERSION%%.*}"
# 	}
#
# Requires: curl, grep, sed (from termux-packages scripts environment).

tur_pkg_update_nodejs() {
	local major="$1"
	local listing latest
	listing="$(
		curl --fail --silent --location --retry 3 \
			"https://nodejs.org/dist/latest-v${major}.x/"
	)" || termux_error_exit "failed to query Node.js releases"
	latest="$(
		echo "${listing}" |
			grep -oE "node-v${major}\.[0-9]+\.[0-9]+\.tar\.xz" |
			head -n1 |
			sed 's|^node-v||; s|\.tar\.xz$||'
	)"
	if [[ -z "${latest}" ]]; then
		termux_error_exit "failed to find latest Node.js ${major} release"
	fi
	termux_pkg_upgrade_version "${latest}"
}

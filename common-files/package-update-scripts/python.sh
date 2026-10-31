# Common auto-update logic for CPython packages (python3.x).
#
# Usage in build.sh:
#
# 	source "$TERMUX_SCRIPTDIR/common-files/package-update-scripts/update-python.sh"
#
# 	termux_pkg_auto_update() {
# 		tur_pkg_update_python "${_MAJOR_VERSION}"
# 	}
#
# Requires: curl, grep, sed, sort (from termux-packages scripts environment).

tur_pkg_update_python() {
	local series="$1"
	local latest
	latest="$(
		curl --fail --silent --location --retry 3 \
			"https://www.python.org/ftp/python/" |
			grep -oE "${series}\.[0-9]+/" |
			sed 's|/$||' |
			sort -V |
			tail -n1
	)" || termux_error_exit "failed to query Python releases"
	if [[ -z "${latest}" ]]; then
		termux_error_exit "failed to find latest Python ${series} release"
	fi
	termux_pkg_upgrade_version "${latest}"
}

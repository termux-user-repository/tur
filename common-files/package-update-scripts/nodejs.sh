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

	# Building Node.js in CI takes a very long time. If the runner has already
	# been up for a while, skip this round and postpone the update to the next
	# scheduled run, to avoid the build being killed mid-way.
	local e=0
	local uptime_now
	uptime_now="$(cat /proc/uptime)"
	local uptime_s="${uptime_now//.*}"
	local uptime_h_limit=2
	local uptime_s_limit=$((uptime_h_limit*60*60))
	[[ -z "${uptime_s}" ]] && [[ "$(uname -o)" != "Android" ]] && e=1
	[[ "${uptime_s}" == 0 ]] && [[ "$(uname -o)" != "Android" ]] && e=1
	[[ "${uptime_s}" -gt "${uptime_s_limit}" ]] && e=1

	if [[ "${e}" != 0 ]]; then
		cat <<- EOL >&2
		WARN: Skipping Node.js ${major} auto update for now!
		latest_version=${latest}
		uptime_now=${uptime_now}
		uptime_s_limit=${uptime_s_limit}
		The update will be postponed to the next scheduled run.
		EOL
		return
	fi

	termux_pkg_upgrade_version "${latest}"
}

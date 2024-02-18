TERMUX_PKG_HOMEPAGE=https://github.com/Winetricks/winetricks
TERMUX_PKG_DESCRIPTION="Work around problems and install applications under Wine"
TERMUX_PKG_LICENSE="LGPL-2.1"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
_COMMIT=a9a556719e4fd28fc5984a963e2d666ec809f554
_COMMIT_DATE=20240216
_COMMIT_TIME=071709
TERMUX_PKG_VERSION="0.0.20240216.071709"
TERMUX_PKG_SRCURL=git+https://github.com/Winetricks/winetricks
TERMUX_PKG_GIT_BRANCH=master
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_MAKE_INSTALL_TARGET="install DESTDIR=${TERMUX_PREFIX%%/usr}"

termux_pkg_auto_update() {
	local api_url="https://api.github.com/repos/Winetricks/winetricks/commits"
	local latest_commit=$(curl -s "${api_url}"| jq .[].sha | head -n1 | sed -e 's|\"||g')
	if [[ -z "${latest_commit}" ]]; then
		echo "WARN: Unable to get latest commit from upstream" >&2
		return
	fi
	if [[ "${latest_commit}" == "${_COMMIT}" ]]; then
		echo "INFO: No update needed. Already at version '${TERMUX_PKG_VERSION}'."
		return
	fi

	local latest_commit_date_tz=$(curl -s "${api_url}/${latest_commit}" | jq .commit.committer.date | sed -e 's|\"||g')
	if [[ -z "${latest_commit_date_tz}" ]]; then
		termux_error_exit "ERROR: Unable to get latest commit date info"
	fi

	local latest_commit_date=$(echo "${latest_commit_date_tz}" | sed -e 's|\(.*\)T\(.*\)Z|\1|' -e 's|\-||g')
	local latest_commit_time=$(echo "${latest_commit_date_tz}" | sed -e 's|\(.*\)T\(.*\)Z|\2|' -e 's|\:||g')

	local latest_version="0.0.${latest_commit_date}.${latest_commit_time}"

	local current_date_epoch=$(date "+%s")
	local _COMMIT_DATE_epoch=$(date -d "${_COMMIT_DATE}" "+%s")
	local current_date_diff=$(((current_date_epoch-_COMMIT_DATE_epoch)/(60*60*24)))
	local cooldown_days=14
	if [[ "${current_date_diff}" -lt "${cooldown_days}" ]]; then
		cat <<- EOL
		INFO: Queuing updates since last push
		Cooldown (days) = ${cooldown_days}
		Days since      = ${current_date_diff}
		EOL
		return
	fi

	if ! dpkg --compare-versions "${latest_version}" gt "${TERMUX_PKG_VERSION}"; then
		termux_error_exit "
		ERROR: Resulting latest version is not counted as an update!
		Latest version  = ${latest_version}
		Current version = ${TERMUX_PKG_VERSION}
		"
	fi

	# unlikely to happen
	if [[ "${latest_commit_date}" -lt "${_COMMIT_DATE}" || \
		"${latest_commit_date}" -eq "${_COMMIT_DATE}" && "${latest_commit_time}" -lt "${_COMMIT_TIME}" ]]; then
		termux_error_exit "
		ERROR: Upstream is older than current package version!
		ERROR: Please report to upstream!
		"
	fi

	sed \
		-e "s|^_COMMIT=.*|_COMMIT=${latest_commit}|" \
		-e "s|^_COMMIT_DATE=.*|_COMMIT_DATE=${latest_commit_date}|" \
		-e "s|^_COMMIT_TIME=.*|_COMMIT_TIME=${latest_commit_time}|" \
		-i "${TERMUX_PKG_BUILDER_DIR}/build.sh"

	termux_pkg_upgrade_version "${latest_version}" --skip-version-check
}

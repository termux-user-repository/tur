TERMUX_PKG_HOMEPAGE=https://gitlab.com/mdds/mdds
TERMUX_PKG_DESCRIPTION="A collection of multi-dimensional data structures and indexing algorithms"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="3.1.0"
TERMUX_PKG_SRCURL=https://gitlab.com/api/v4/projects/mdds%2Fmdds/packages/generic/source/${TERMUX_PKG_VERSION}/mdds-${TERMUX_PKG_VERSION}.tar.xz
TERMUX_PKG_SHA256=ca295f4c86968a7eb1f5d503ff7ae180e6605210cfb26d01658be42048c0924c
TERMUX_PKG_AUTO_UPDATE=true

termux_pkg_auto_update() {
	local latest_tag
	latest_tag="$(
		termux_gitlab_api_get_tag \
			"${TERMUX_PKG_HOMEPAGE}" "${TERMUX_PKG_UPDATE_TAG_TYPE}" "${TERMUX_GITLAB_API_HOST}"
	)"
	if [[ -z "${latest_tag}" ]]; then
		termux_error_exit "ERROR: Unable to get tag from ${TERMUX_PKG_HOMEPAGE}"
	fi
	termux_pkg_upgrade_version "${latest_tag}"
}

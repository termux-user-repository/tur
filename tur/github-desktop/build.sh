TERMUX_PKG_HOMEPAGE=https://desktop-plus.org
TERMUX_PKG_DESCRIPTION="GitHub Desktop (Desktop Plus fork), a GUI for Git and GitHub"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="Gouranga Das Samrat <gouranga.das.khulna@gmail.com>"
TERMUX_PKG_VERSION="3.6.7.1"

# Submodules of desktop-plus at v${TERMUX_PKG_VERSION}, they are not part of the
# GitHub source tarball. These pins are rewritten by termux_pkg_auto_update()
# at the end of this file, see helpers.sh.
_GEMOJI_COMMIT="50865e8895c54037bf06c4c1691aa925d030a59d"
_GITIGNORE_COMMIT="81ceb66b6b9d32324c98fe1c51f27d2eb9451865"
_CHOOSEALICENSE_COMMIT="aed28f9933c9e8435c0f1d07aa563c0a830859bc"

TERMUX_PKG_SRCURL=(
	"https://github.com/desktop-plus/desktop-plus/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
	"https://github.com/github/gemoji/archive/${_GEMOJI_COMMIT}.tar.gz"
	"https://github.com/github/gitignore/archive/${_GITIGNORE_COMMIT}.tar.gz"
	"https://github.com/github/choosealicense.com/archive/${_CHOOSEALICENSE_COMMIT}.tar.gz"
)
TERMUX_PKG_SHA256=(
	88abb1f1141be0d8fcfc838e4a91771d4a57a83b413245bc34b24c209c19fc51
	c8a05fd2c2737dc2254ba1306af96bae4f116f4ab909e1505a9a0ea0ea5d52fb
	760da32d8eeb6dc3518b3836b3f0579014413499f069d7829459295d2b167894
	0ea34074b3051a0ad32f652a1740c02197a5ba705c9e194076c5922f7345bf71
)
TERMUX_PKG_AUTO_UPDATE=true

TERMUX_PKG_DEPENDS="electron42, git, libsecret, libx11, openssh, xdg-utils"
TERMUX_PKG_RECOMMENDS="gnome-keyring, git-lfs"
TERMUX_PKG_BUILD_DEPENDS="electron42-headers, pkg-config"
TERMUX_PKG_BUILD_IN_SRC=true
# Chromium/Electron don't support i686 on Linux.
TERMUX_PKG_EXCLUDED_ARCHES="i686"
TERMUX_PKG_ON_DEVICE_BUILD_NOT_SUPPORTED=true

# shellcheck source=tur/github-desktop/helpers.sh
source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"

termux_step_post_get_source() {
	__desktop_plus_place_submodules
}

termux_step_make() {
	termux_setup_electron "${TERMUX_PKG_SRCDIR}/package.json"

	__desktop_plus_export_commit_id
	__desktop_plus_setup_yarn
	__desktop_plus_yarn_install
	__desktop_plus_build_native_modules

	# Upstream's own switch: only lay out the app in out/, the Electron
	# binary is provided by the electronNN package.
	DESKTOP_SKIP_PACKAGE=1 yarn build:prod
}

termux_step_make_install() {
	[[ -e "${TERMUX_PKG_SRCDIR}/out/main.js" ]] ||
		termux_error_exit "Built app not found in out/"

	local dest="${TERMUX_PREFIX}/opt/github-desktop"
	rm -rf "${dest}"
	mkdir -p "${dest}/resources"
	cp -r "${TERMUX_PKG_SRCDIR}/out" "${dest}/resources/app"

	# Install the launcher shim. See: tur/github-desktop/github-desktop-shim.sh
	sed -e "s|@TERMUX_PREFIX@|${TERMUX_PREFIX}|g" \
		"${TERMUX_PKG_BUILDER_DIR}/github-desktop-shim.sh" \
		>"${TERMUX_PREFIX}/bin/github-desktop"
	chmod 0755 "${TERMUX_PREFIX}/bin/github-desktop"

	__desktop_plus_install_files "${dest}"
}

termux_step_create_debscripts() {
	cat <<-EOF >postrm
		#!${TERMUX_PREFIX}/bin/sh
		if [ "\$1" = "remove" ] || [ "\$1" = "purge" ]; then
			rm -rf "${TERMUX_PREFIX}/opt/github-desktop"
		fi
	EOF
}

termux_pkg_auto_update() {
	local latest_tag
	latest_tag="$(termux_github_api_get_tag)"
	[[ -n "${latest_tag}" ]] || termux_error_exit "Unable to get tag from ${TERMUX_PKG_SRCURL[0]}"
	[[ "${latest_tag}" =~ ^v?[0-9]+(\.[0-9]+){3}$ ]] ||
		termux_error_exit "Unexpected Desktop Plus tag '${latest_tag}'"
	latest_tag="${latest_tag#v}"

	# Only rewrite the pins when an update will really happen.
	if termux_pkg_is_update_needed "${TERMUX_PKG_VERSION#*:}" "${latest_tag}" &&
		[[ "${BUILD_PACKAGES}" != "false" && -z "${TERMUX_PKG_UPGRADE_VERSION_DRY_RUN:-}" ]]; then
		__desktop_plus_resolve_submodule_pins "v${latest_tag}"
		sed \
			-e "s/^\(_GEMOJI_COMMIT=\).*/\1\"${_NEW_GEMOJI_COMMIT}\"/" \
			-e "s/^\(_GITIGNORE_COMMIT=\).*/\1\"${_NEW_GITIGNORE_COMMIT}\"/" \
			-e "s/^\(_CHOOSEALICENSE_COMMIT=\).*/\1\"${_NEW_CHOOSEALICENSE_COMMIT}\"/" \
			-i "${TERMUX_PKG_BUILDER_DIR}/build.sh"

		# Not fatal, but worth a look: the build uses Termux's Electron.
		echo "desktop-plus ${latest_tag} is built with Electron ${_NEW_ELECTRON_MAJOR} upstream."
	fi

	termux_pkg_upgrade_version "${latest_tag}"
}

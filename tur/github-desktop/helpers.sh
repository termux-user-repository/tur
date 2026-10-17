# shellcheck shell=bash

# Source submodules of desktop-plus, they are not part of the GitHub source
# tarball. Format: <path in the source tree>:<repository>:<build.sh variable>
__DESKTOP_PLUS_SUBMODULES=(
	"gemoji:github/gemoji:_GEMOJI_COMMIT"
	"app/static/common/gitignore:github/gitignore:_GITIGNORE_COMMIT"
	"app/static/common/choosealicense.com:github/choosealicense.com:_CHOOSEALICENSE_COMMIT"
)

# Move the submodule archives (extra SRCURL entries) to where upstream
# expects the submodules.
__desktop_plus_place_submodules() {
	local entry path repo var commit dir
	for entry in "${__DESKTOP_PLUS_SUBMODULES[@]}"; do
		IFS=: read -r path repo var <<<"${entry}"
		commit="${!var}"
		dir="${TERMUX_PKG_SRCDIR}/${repo#*/}-${commit}"
		[[ -d "${dir}" ]] || termux_error_exit "Submodule archive not found: ${dir}"
		rm -rf "${TERMUX_PKG_SRCDIR:?}/${path}"
		mv "${dir}" "${TERMUX_PKG_SRCDIR}/${path}"
	done
}

# The build wants the commit id, but the source tarball has no .git directory.
# GitHub stores it in the tarball header.
__desktop_plus_export_commit_id() {
	local tarball
	tarball="${TERMUX_PKG_CACHEDIR}/$(basename "${TERMUX_PKG_SRCURL[0]}")"
	# (process substitution, git exits after the header and gzip gets SIGPIPE)
	CIRCLE_SHA1="$(git get-tar-commit-id < <(gzip -dc "${tarball}"))"
	[[ -n "${CIRCLE_SHA1}" ]] || termux_error_exit "Unable to get the commit id from ${tarball}"
	export CIRCLE_SHA1
}

# Upstream calls "yarn" from vendor/ and its own scripts call it again.
__desktop_plus_setup_yarn() {
	local yarn_dir="${TERMUX_PKG_TMPDIR}/yarn-bin"
	mkdir -p "${yarn_dir}"
	cat >"${yarn_dir}/yarn" <<-EOF2
		#!/bin/sh
		exec node "${TERMUX_PKG_SRCDIR}/vendor/yarn-1.21.1.js" "\$@"
	EOF2
	chmod 0755 "${yarn_dir}/yarn"
	export PATH="${yarn_dir}:${PATH}"
}

# Install scripts are skipped on purpose: the root postinstall wants a git
# checkout, and the native addons would fetch glibc prebuilds (and dugite an
# embedded git), none of which can run on Android.
# --ignore-engines: some dev dependencies only list old node versions, which is
# irrelevant here.
__desktop_plus_yarn_install() {
	local args=(--frozen-lockfile --ignore-scripts --ignore-engines --non-interactive)
	yarn install "${args[@]}"
	yarn --cwd app install "${args[@]}"
}

# The binding.gyp files of desktop-trampoline, printenvz and process-proxy
# use -Werror together with -pie, which clang rejects while compiling:
#   clang: error: argument unused during compilation: '-pie'
# Drop -Werror (but keep -Werror=format-security), warnings are fine here.
__desktop_plus_node_gyp_rebuild() {
	sed -E -i "s/['\"]-Werror['\"],?//g" binding.gyp

	node "${TERMUX_PKG_SRCDIR}/node_modules/node-gyp/bin/node-gyp.js" rebuild \
		--arch="${NPM_CONFIG_ARCH}" \
		--nodedir="${npm_config_nodedir}"
}

# Run tsc in app/node_modules/<module> and check that its "main" file exists.
__desktop_plus_tsc_build() {
	local module_dir="${TERMUX_PKG_SRCDIR}/app/node_modules/$1"
	local main
	main="$(jq -r '.main' "${module_dir}/package.json")"
	(
		cd "${module_dir}"
		node "${TERMUX_PKG_SRCDIR}/node_modules/typescript/bin/tsc" -p .
		[[ -f "${main}" ]] || termux_error_exit "$1: ${main} was not built"
	)
}

# Build the native modules from source. Most of the addons are empty on Linux
# but the bundler still expects their .node files to exist.
__desktop_plus_build_native_modules() {
	local module
	for module in desktop-trampoline desktop-notifications fs-admin keytar registry-js; do
		(
			cd "${TERMUX_PKG_SRCDIR}/app/node_modules/${module}"
			__desktop_plus_node_gyp_rebuild
		)
	done

	# The install scripts of these local modules are "node-gyp rebuild && tsc"
	# (windows-argv-parser has no native part on Linux). Their TypeScript
	# output (dist/ or build/, the "main" of each package) is missing without
	# it and webpack can not load the .ts files.
	local ts_module
	for ts_module in desktop-trampoline desktop-notifications windows-argv-parser; do
		__desktop_plus_tsc_build "${ts_module}"
	done

	# printenvz is a local module, build.ts copies build/Release/printenvz
	(
		cd "${TERMUX_PKG_SRCDIR}/vendor/printenvz"
		__desktop_plus_node_gyp_rebuild
	)
	mkdir -p "${TERMUX_PKG_SRCDIR}/node_modules/printenvz/build"
	rm -rf "${TERMUX_PKG_SRCDIR}/node_modules/printenvz/build/Release"
	cp -a "${TERMUX_PKG_SRCDIR}/vendor/printenvz/build/Release" \
		"${TERMUX_PKG_SRCDIR}/node_modules/printenvz/build/Release"

	# process-proxy: build.ts expects bin/process-proxy-linux-<arch>
	local proxy_dir="${TERMUX_PKG_SRCDIR}/node_modules/process-proxy"
	local proxy_bin="process-proxy-linux-${NPM_CONFIG_ARCH}"
	(
		cd "${proxy_dir}"
		__desktop_plus_node_gyp_rebuild
		mkdir -p bin
		cp "build/Release/${proxy_bin}" "bin/${proxy_bin}"
	)
}

# Read the pinned submodule commits of a desktop-plus tag.
# Sets _NEW_GEMOJI_COMMIT, _NEW_GITIGNORE_COMMIT and _NEW_CHOOSEALICENSE_COMMIT.
__desktop_plus_resolve_submodule_pins() {
	local tag="$1"
	local tmp
	tmp="$(mktemp -d)"
	git clone --quiet --depth 1 --filter=blob:none --no-checkout \
		--branch "${tag}" "https://github.com/desktop-plus/desktop-plus.git" "${tmp}" ||
		{
			rm -rf "${tmp}"
			termux_error_exit "Unable to clone desktop-plus ${tag}"
		}

	local entry path var commit
	for entry in "${__DESKTOP_PLUS_SUBMODULES[@]}"; do
		IFS=: read -r path _ var <<<"${entry}"
		commit="$(git -C "${tmp}" ls-tree HEAD "${path}" | awk '$2 == "commit" { print $3 }')"
		if [[ ! "${commit}" =~ ^[0-9a-f]{40}$ ]]; then
			rm -rf "${tmp}"
			termux_error_exit "Submodule ${path} not found in desktop-plus ${tag}"
		fi
		printf -v "_NEW${var}" '%s' "${commit}"
	done

	# Electron is provided by the electronNN package, a different major than
	# the one upstream builds with can break the app.
	local upstream_electron
	upstream_electron="$(git -C "${tmp}" show HEAD:package.json | jq -r '.devDependencies.electron // "unknown"')"
	rm -rf "${tmp}"
	_NEW_ELECTRON_MAJOR="${upstream_electron%%.*}"
}

__desktop_plus_install_files() {
	local dest="$1"

	# termux-tools' xdg-open can't open URLs, use xdg-utils-xdg-open
	install -Dm755 /dev/stdin "${dest}/bin/xdg-open" <<-XDG_OPEN
		#!${TERMUX_PREFIX}/bin/sh
		exec "${TERMUX_PREFIX}/bin/xdg-utils-xdg-open" "\$@"
	XDG_OPEN

	local size
	for size in 32 64 128 256 512 1024; do
		install -Dm644 "${TERMUX_PKG_SRCDIR}/app/static/linux/logos/${size}x${size}.png" \
			"${TERMUX_PREFIX}/share/icons/hicolor/${size}x${size}/apps/github-desktop.png"
	done

	install -Dm644 /dev/stdin "${TERMUX_PREFIX}/share/applications/github-desktop.desktop" <<-DESKTOP
		[Desktop Entry]
		Name=GitHub Desktop
		Comment=${TERMUX_PKG_DESCRIPTION}
		GenericName=Git Client
		Exec=${TERMUX_PREFIX}/bin/github-desktop %U
		Icon=github-desktop
		Terminal=false
		Type=Application
		Categories=GNOME;GTK;Development;
		StartupWMClass=Desktop Plus
		MimeType=x-scheme-handler/x-github-client;x-scheme-handler/x-github-desktop-auth;x-scheme-handler/x-github-desktop-dev-auth;
	DESKTOP
}

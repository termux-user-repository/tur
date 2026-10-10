TERMUX_PKG_HOMEPAGE=https://github.com/shiftkey/desktop
TERMUX_PKG_DESCRIPTION="Unofficial GitHub Desktop for Linux, a GUI for Git and GitHub"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="Gouranga Das Samrat <gouranga.das.khulna@gmail.com>"
TERMUX_PKG_VERSION="3.4.13"
# Submodules of shiftkey/desktop at release-${TERMUX_PKG_VERSION}-linux${_LINUX_REV},
# they are not part of the GitHub source tarball.
_LINUX_REV="1"
_GEMOJI_COMMIT=50865e8895c54037bf06c4c1691aa925d030a59d
_GITIGNORE_COMMIT=4488915eec0b3a45b5c63ead28f286819c0917de
_CHOOSEALICENSE_COMMIT=aed28f9933c9e8435c0f1d07aa563c0a830859bc
TERMUX_PKG_SRCURL=(
	"https://github.com/shiftkey/desktop/archive/refs/tags/release-${TERMUX_PKG_VERSION}-linux${_LINUX_REV}.tar.gz"
	"https://github.com/github/gemoji/archive/${_GEMOJI_COMMIT}.tar.gz"
	"https://github.com/github/gitignore/archive/${_GITIGNORE_COMMIT}.tar.gz"
	"https://github.com/github/choosealicense.com/archive/${_CHOOSEALICENSE_COMMIT}.tar.gz"
)
TERMUX_PKG_SHA256=(
	b84f9529dea2e5aeefb2e670b4a702046db59629e3b312129091d6799f20fc34
	c8a05fd2c2737dc2254ba1306af96bae4f116f4ab909e1505a9a0ea0ea5d52fb
	bd9e8d87081cdfaa03561df8a024926f03b7038492c73bcf7f610d45cb5c27b8
	0ea34074b3051a0ad32f652a1740c02197a5ba705c9e194076c5922f7345bf71
)
TERMUX_PKG_DEPENDS="electron42, git, libsecret, libx11, openssh, xdg-utils"
TERMUX_PKG_RECOMMENDS="gnome-keyring"
TERMUX_PKG_BUILD_DEPENDS="electron42-headers, pkg-config"
TERMUX_PKG_BUILD_IN_SRC=true
# Chromium/Electron don't support i686 on Linux.
TERMUX_PKG_EXCLUDED_ARCHES="i686"
TERMUX_PKG_ON_DEVICE_BUILD_NOT_SUPPORTED=true

termux_step_post_get_source() {
	# Put the submodules where upstream expects them
	local _submodule
	for _submodule in \
		"gemoji:gemoji-${_GEMOJI_COMMIT}" \
		"app/static/common/gitignore:gitignore-${_GITIGNORE_COMMIT}" \
		"app/static/common/choosealicense.com:choosealicense.com-${_CHOOSEALICENSE_COMMIT}"; do
		local _path="${_submodule%%:*}"
		local _dir="${_submodule#*:}"
		if [[ ! -d "$TERMUX_PKG_SRCDIR/$_dir" ]]; then
			termux_error_exit "Submodule archive not found: $_dir"
		fi
		rm -rf "${TERMUX_PKG_SRCDIR:?}/$_path"
		mv "$TERMUX_PKG_SRCDIR/$_dir" "$TERMUX_PKG_SRCDIR/$_path"
	done

	# Upstream pins its own electron version, informational only
	local _electron_version
	_electron_version="$(jq -r '.devDependencies.electron // .dependencies.electron' \
		"$TERMUX_PKG_SRCDIR/package.json")"
	local _available_version
	_available_version="$(. "$TERMUX_SCRIPTDIR/x11-packages/electron42-host-tools/build.sh"; echo "$TERMUX_PKG_VERSION")"
	echo "GitHub Desktop was built/tested against Electron $_electron_version; this build uses $_available_version instead."
}

termux_step_make() {
	termux_setup_nodejs

	unset PREFIX prefix

	case "$TERMUX_ARCH" in
		"aarch64")
			export NPM_CONFIG_ARCH=arm64
		;;
		"arm")
			export NPM_CONFIG_ARCH=arm
		;;
		"x86_64")
			export NPM_CONFIG_ARCH=x64
		;;
		*)
			termux_error_exit "Unsupported arch: $TERMUX_ARCH"
		;;
	esac
	export npm_config_arch="$NPM_CONFIG_ARCH"

	# Build native addons (keytar, fs-admin, ...) against electron headers
	export npm_config_nodedir="$TERMUX_PREFIX/opt/electron42-host-tools/node_headers"
	export CXX="$CXX -v -L$TERMUX_PREFIX/lib"

	# Skip electron binary download
	export ELECTRON_SKIP_BINARY_DOWNLOAD=1

	# The source tarball has no .git directory, but the build wants the commit
	local _tarball
	_tarball="$TERMUX_PKG_CACHEDIR/$(basename "${TERMUX_PKG_SRCURL[0]}")"
	# (process substitution, git exits after the header and gzip gets SIGPIPE)
	CIRCLE_SHA1="$(git get-tar-commit-id < <(gzip -dc "$_tarball"))"
	if [[ -z "$CIRCLE_SHA1" ]]; then
		termux_error_exit "Unable to get the commit id from $_tarball"
	fi
	export CIRCLE_SHA1

	# Upstream runs yarn from vendor/ and its scripts call "yarn" again
	local _yarn_dir="$TERMUX_PKG_TMPDIR/yarn-bin"
	mkdir -p "$_yarn_dir"
	cat > "$_yarn_dir/yarn" <<-EOF
	#!/bin/sh
	exec node "$TERMUX_PKG_SRCDIR/vendor/yarn-1.21.1.js" "\$@"
	EOF
	chmod 0755 "$_yarn_dir/yarn"
	export PATH="$_yarn_dir:$PATH"

	# Install scripts are skipped on purpose: the root postinstall wants a git
	# checkout, and the native addons would fetch glibc prebuilds (and dugite
	# an embedded git), none of which can run on Android.
	# --ignore-engines: some dev dependencies (eslint plugins) only list node<=20,
	# which is irrelevant here, the build tools run fine on the newer node.
	yarn install --frozen-lockfile --ignore-scripts --ignore-engines --non-interactive
	yarn --cwd app install --frozen-lockfile --ignore-scripts --ignore-engines --non-interactive

	# Build the native addons from source instead. Most of them are empty on
	# Linux but the bundler still expects their .node files to exist.
	local _module
	for _module in desktop-trampoline desktop-notifications fs-admin-forked keytar-forked registry-js; do
		(
			cd "app/node_modules/$_module"
			node "$TERMUX_PKG_SRCDIR/node_modules/node-gyp/bin/node-gyp.js" rebuild \
				--arch="$NPM_CONFIG_ARCH" \
				--nodedir="$npm_config_nodedir"
		)
	done

	yarn build:prod
}

termux_step_make_install() {
	local _app_dir
	_app_dir="$(find dist -mindepth 3 -maxdepth 3 -type d -path "*/resources/app" | head -n 1)"
	if [[ -z "$_app_dir" || ! -e "$_app_dir/main.js" ]]; then
		termux_error_exit "Built app not found under dist/"
	fi

	local dest="$TERMUX_PREFIX/opt/github-desktop"
	rm -rf "$dest"
	mkdir -p "$dest/resources"
	cp -r "$_app_dir" "$dest/resources/app"

	# termux-tools' xdg-open can't open URLs, use xdg-utils-xdg-open
	install -Dm755 /dev/stdin \
		"$dest/bin/xdg-open" <<-XDG_OPEN
	#!$TERMUX_PREFIX/bin/sh
	exec "$TERMUX_PREFIX/bin/xdg-utils-xdg-open" "\$@"
	XDG_OPEN

	# Install the launcher shim. See: tur/github-desktop/github-desktop-shim.sh
	sed -e "s|@TERMUX_PREFIX@|${TERMUX_PREFIX}|g" \
		"$TERMUX_PKG_BUILDER_DIR/github-desktop-shim.sh" \
		> "$TERMUX_PREFIX/bin/github-desktop"
	chmod 0755 "$TERMUX_PREFIX/bin/github-desktop"

	install -Dm600 app/static/linux/logos/512x512.png \
		"$TERMUX_PREFIX/share/icons/hicolor/512x512/apps/github-desktop.png"

	mkdir -p "$TERMUX_PREFIX/share/applications"
	cat > "$TERMUX_PREFIX/share/applications/github-desktop.desktop" <<-DESKTOP
	[Desktop Entry]
	Name=GitHub Desktop
	Comment=$TERMUX_PKG_DESCRIPTION
	Exec=$TERMUX_PREFIX/bin/github-desktop %U
	Icon=github-desktop
	Type=Application
	Categories=GNOME;GTK;Development;
	StartupWMClass=GitHub Desktop
	MimeType=x-scheme-handler/x-github-client;x-scheme-handler/x-github-desktop-auth;x-scheme-handler/x-github-desktop-dev-auth;
	DESKTOP
}

termux_step_create_debscripts() {
	cat <<- EOF > postrm
	#!$TERMUX_PREFIX/bin/sh
	if [ "\$1" = "remove" ] || [ "\$1" = "purge" ]; then
		rm -rf "$TERMUX_PREFIX/opt/github-desktop"
	fi
	EOF
}

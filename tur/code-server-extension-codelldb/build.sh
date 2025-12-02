TERMUX_PKG_HOMEPAGE=https://github.com/vadimcn/codelldb
TERMUX_PKG_DESCRIPTION="A native debugger extension for code-server based on LLDB"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="1.12.0"
TERMUX_PKG_SRCURL="https://raw.githubusercontent.com/vadimcn/codelldb/refs/tags/v$TERMUX_PKG_VERSION/LICENSE"
TERMUX_PKG_SHA256=6eedaf734957b02e4bcc408ea0ecb55de0f6b2ab18e92339327e863fdad86aed
TERMUX_PKG_AUTO_UPDATE=true
# codelldb does not work properly on 32-bit Android
TERMUX_PKG_EXCLUDED_ARCHES="arm, i686"
TERMUX_PKG_DEPENDS="code-server, vsix-package-codelldb"

termux_pkg_auto_update() {
	# update when https://github.com/termux/termux-packages/blob/master/x11-packages/codelldb
	# receives an update
	# does not handle revision-bumps, only automatic updates.
	# If codelldb is revision-bumped, also revision-bump code-server-extension-codelldb,
	# but code-server-extension-codelldb can be revision-bumped safely if necessary
	# without revision-bumping codelldb.
	local codelldb_build_sh="$TERMUX_SCRIPTDIR/x11-packages/codelldb/build.sh"
	local latest_version=$(bash -c ". $codelldb_build_sh; echo \${TERMUX_PKG_VERSION#*:}")
	termux_pkg_upgrade_version "${latest_version}"
}

termux_step_get_source() {
	mkdir -p "$TERMUX_PKG_SRCDIR"
	termux_download "$TERMUX_PKG_SRCURL" "$TERMUX_PKG_SRCDIR/LICENSE" "$TERMUX_PKG_SHA256"
}

termux_step_make_install() {
	touch .placeholder
	install -DTm644 .placeholder \
		"$TERMUX_PREFIX/opt/vsix-packages/.placeholder-for-$TERMUX_PKG_NAME"
}

termux_step_create_debscripts() {
	local codelldb_build_sh="$TERMUX_SCRIPTDIR/x11-packages/codelldb/build.sh"
	local codelldb_version=$(bash -c ". $codelldb_build_sh; echo \${TERMUX_PKG_VERSION#*:}")
	local codelldb_revision=$(bash -c ". $codelldb_build_sh; echo \${TERMUX_PKG_REVISION-}")
	# based on termux_step_start_build()
	local codelldb_fullversion="$codelldb_version"
	if [[ -n "$codelldb_revision" ]]; then
		codelldb_fullversion+="-$codelldb_revision"
	elif [[ "$TERMUX_PACKAGE_FORMAT" == "pacman" ]]; then
		codelldb_fullversion+="-0"
	fi

	cat <<-EOF >./postinst
		#!${TERMUX_PREFIX}/bin/sh
		code-server --install-extension "$TERMUX_PREFIX/opt/vsix-packages/codelldb-$codelldb_fullversion.vsix"
		exit 0
	EOF
	cat <<-EOF >./prerm
		#!${TERMUX_PREFIX}/bin/sh
		if [ "$TERMUX_PACKAGE_FORMAT" = "debian" ] && [ "\$1" != "remove" ]; then
			exit 0
		fi
		code-server --uninstall-extension vadimcn.vscode-lldb
		exit 0
	EOF
	chmod +x ./postinst ./prerm
}

TERMUX_PKG_HOMEPAGE=https://www.beekeeperstudio.io
TERMUX_PKG_DESCRIPTION="Modern and easy to use SQL client and database manager"
TERMUX_PKG_LICENSE="GPL-3.0, custom"
TERMUX_PKG_LICENSE_FILE="LICENSE.md, LICENSE-COMMERCIAL.md"
TERMUX_PKG_MAINTAINER="Gouranga Das Samrat <gouranga.das.khulna@gmail.com>"
TERMUX_PKG_VERSION="6.3.0"
TERMUX_PKG_SRCURL="https://github.com/beekeeper-studio/beekeeper-studio/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=212ab8c0edd5e6e103827a8b8e11dec5ef8b0b4d9257027a776e9e71c0e48f50
TERMUX_PKG_DEPENDS="electron43, libx11"
TERMUX_PKG_BUILD_DEPENDS="electron43-headers, pkg-config"
TERMUX_PKG_BUILD_IN_SRC=true
# Chromium/Electron don't support i686 on Linux.
TERMUX_PKG_EXCLUDED_ARCHES="i686"
TERMUX_PKG_ON_DEVICE_BUILD_NOT_SUPPORTED=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_TAG_TYPE="latest-release-tag"

termux_step_make() {
	termux_setup_electron "$TERMUX_PKG_SRCDIR/apps/studio/package.json"

	local _pnpm_version _pnpm_dir
	_pnpm_version="$(jq -r '.packageManager | sub("^pnpm@"; "") | sub("\\+.*$"; "")' package.json)"
	_pnpm_dir="$TERMUX_PKG_TMPDIR/pnpm"
	mkdir -p "$_pnpm_dir"
	npm install --prefix "$_pnpm_dir" "pnpm@${_pnpm_version}"
	export PATH="$_pnpm_dir/node_modules/.bin:$PATH"
	export PNPM_CONFIG_PM_ON_FAIL=ignore

	# Install scripts are skipped, sqlanywhere's one exits non-zero without
	# the SAP client. better-sqlite3 is built by hand below
	pnpm install --frozen-lockfile --ignore-scripts --fetch-timeout 600000

	# libsql, duckdb and sqlanywhere have no android binaries and their loaders
	# throw on require, which stops the app at startup. Stub them to fail on use.
	# With pnpm, node_modules/<name> is a symlink into node_modules/.pnpm, so the
	# real package directories are replaced to keep the layout (and the
	# dependency tree that electron-builder collects) intact
	local _name _dir
	for _name in libsql @duckdb/node-api sqlanywhere; do
		while IFS= read -r _dir; do
			rm -rf "${_dir:?}"
			mkdir -p "$_dir"
			echo "{\"name\":\"$_name\",\"version\":\"0.0.0\",\"main\":\"index.js\"}" \
				> "$_dir/package.json"
			sed "s|@NAME@|$_name|g" "$TERMUX_PKG_BUILDER_DIR/unsupported-driver-stub.js" \
				> "$_dir/index.js"
		done < <(find node_modules/.pnpm -type d -path "*/node_modules/$_name" -prune)
	done

	# Optional prebuilds of those drivers that pnpm picked for the build host,
	# and the symlinks to them left dangling in the virtual store
	rm -rf node_modules/.pnpm/@duckdb+node-bindings* \
		node_modules/.pnpm/@libsql+{darwin,linux,win32}-*
	find node_modules/.pnpm -xtype l \
		\( -path "*/@duckdb/node-bindings*" -o -path "*/@libsql/*" \) -delete

	# better-sqlite3 has to be built from source against the electron headers
	# set above, its prebuilds target the build host
	while IFS= read -r _dir; do
		(cd "$_dir" && npm run build-release)
		# Its loader prefers prebuilds/ and takes this android as musl,
		# so the musl prebuild would be loaded instead of the one built here
		rm -rf "$_dir/prebuilds"
	done < <(find node_modules/.pnpm -type d -path "*/node_modules/better-sqlite3" -prune)

	# "build" builds ui-kit first (build:deps), then bundles the app
	export NODE_OPTIONS="--max-old-space-size=4096"
	pnpm --filter beekeeper-studio build

	# Only app.asar and the extra resources are needed from electron-builder;
	# termux_setup_electron already provides a placeholder "electron" binary
	# in $TERMUX_ELECTRON_DIST
	(
		cd apps/studio
		pnpm exec electron-builder \
			--linux --"$TERMUX_ELECTRON_ARCH" --dir \
			--config ./electron-builder-config.js \
			-c.electronDist="$TERMUX_ELECTRON_DIST" \
			-c.electronVersion="$TERMUX_ELECTRON_VERSION" \
			-c.npmRebuild=false \
			--publish never
	)
}

termux_step_make_install() {
	local _dist_dir
	_dist_dir=$(find apps/studio/dist_electron -maxdepth 1 -type d -name "*-unpacked")
	if [[ -z "$_dist_dir" || ! -e "$_dist_dir/resources/app.asar" ]]; then
		termux_error_exit "electron-builder output not found under apps/studio/dist_electron"
	fi

	local dest="$TERMUX_PREFIX/opt/beekeeper-studio"
	rm -rf "$dest"
	mkdir -p "$dest"
	cp -r "$_dist_dir/resources" "$dest/resources"

	# Other prebuilt .node files came with optional dependencies and match the
	# build host, better-sqlite3 is the only one built for the target
	if [[ -d "$dest/resources/app.asar.unpacked" ]]; then
		find "$dest/resources/app.asar.unpacked" -name "*.node" \
			! -path "*/better-sqlite3/build/Release/better_sqlite3.node" -delete
	fi

	# Install the launcher shim. See: tur/beekeeper-studio/beekeeper-studio-shim.sh
	sed -e "s|@TERMUX_PREFIX@|${TERMUX_PREFIX}|g" \
		"$TERMUX_PKG_BUILDER_DIR/beekeeper-studio-shim.sh" \
		> "$TERMUX_PREFIX/bin/beekeeper-studio"
	chmod 0755 "$TERMUX_PREFIX/bin/beekeeper-studio"

	install -Dm600 apps/studio/public/icons/png/512x512.png \
		"$TERMUX_PREFIX/share/icons/hicolor/512x512/apps/beekeeper-studio.png"

	mkdir -p "$TERMUX_PREFIX/share/applications"
	cat > "$TERMUX_PREFIX/share/applications/beekeeper-studio.desktop" <<-DESKTOP
	[Desktop Entry]
	Name=Beekeeper Studio
	Comment=$TERMUX_PKG_DESCRIPTION
	Exec=$TERMUX_PREFIX/bin/beekeeper-studio %U
	Icon=beekeeper-studio
	Type=Application
	Categories=Development;Database;
	StartupWMClass=beekeeper-studio
	MimeType=application/vnd.sqlite3;x-scheme-handler/postgresql;x-scheme-handler/postgres;x-scheme-handler/psql;x-scheme-handler/mysql;x-scheme-handler/mariadb;x-scheme-handler/sqlserver;x-scheme-handler/mssql;x-scheme-handler/sqlite;x-scheme-handler/redis;x-scheme-handler/rediss;x-scheme-handler/cockroachdb;x-scheme-handler/redshift;x-scheme-handler/tidb;
	DESKTOP
}

termux_step_create_debscripts() {
	cat <<- EOF > postrm
	#!$TERMUX_PREFIX/bin/sh
	if [ "\$1" = "remove" ] || [ "\$1" = "purge" ]; then
		rm -rf "$TERMUX_PREFIX/opt/beekeeper-studio"
	fi
	EOF
}

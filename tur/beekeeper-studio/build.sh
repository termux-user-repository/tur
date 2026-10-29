TERMUX_PKG_HOMEPAGE=https://www.beekeeperstudio.io
TERMUX_PKG_DESCRIPTION="Modern and easy to use SQL client and database manager"
TERMUX_PKG_LICENSE="GPL-3.0, custom"
TERMUX_PKG_LICENSE_FILE="LICENSE.md, LICENSE-COMMERCIAL.md"
TERMUX_PKG_MAINTAINER="Gouranga Das Samrat <gouranga.das.khulna@gmail.com>"
TERMUX_PKG_VERSION="6.2.0"
TERMUX_PKG_SRCURL="https://github.com/beekeeper-studio/beekeeper-studio/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=cac9dfd4c8bf44608baaa4bc03dccc768926610c8239f4e586b67fc47df3f926
TERMUX_PKG_DEPENDS="electron42, libx11"
TERMUX_PKG_BUILD_DEPENDS="electron42-headers, pkg-config, yarn"
TERMUX_PKG_BUILD_IN_SRC=true
# Chromium/Electron don't support i686 on Linux.
TERMUX_PKG_EXCLUDED_ARCHES="i686"
TERMUX_PKG_ON_DEVICE_BUILD_NOT_SUPPORTED=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_TAG_TYPE="latest-release-tag"

termux_step_make() {
	termux_setup_electron "$TERMUX_PKG_SRCDIR/apps/studio/package.json"

	# The yarn in $TERMUX_PREFIX/bin has a shebang for the target node,
	# so wrap yarn.js with the host node
	local bin="$TERMUX_PKG_BUILDDIR/_bin"
	mkdir -p "$bin"
	cat > "$bin/yarn" <<-EOF
		#!/bin/sh
		exec node $TERMUX_PREFIX/share/yarn/bin/yarn.js "\$@"
	EOF
	chmod 0755 "$bin/yarn"
	export PATH="$bin:$PATH"

	# better-sqlite3 12.x doesn't compile against the V8 headers of electron 42,
	# 13.x uses Node-API. This changes the lockfile so --frozen-lockfile can't be used
	jq '.resolutions["better-sqlite3"] = "^13.0.3"' package.json > package.json.new
	mv package.json.new package.json

	# Install scripts are skipped, sqlanywhere's one exits non-zero without
	# the SAP client. better-sqlite3 is built by hand below
	yarn install --ignore-scripts --network-timeout 600000

	# libsql, duckdb and sqlanywhere have no android binaries and their loaders
	# throw on require, which stops the app at startup. Stub them to fail on use
	local _name _dir
	for _name in libsql @duckdb/node-api sqlanywhere; do
		for _dir in node_modules apps/studio/node_modules; do
			[[ -d "$_dir/$_name" ]] || continue
			rm -rf "${_dir:?}/$_name"
			mkdir -p "$_dir/$_name"
			echo "{\"name\":\"$_name\",\"version\":\"0.0.0\",\"main\":\"index.js\"}" \
				> "$_dir/$_name/package.json"
			sed "s|@NAME@|$_name|g" "$TERMUX_PKG_BUILDER_DIR/unsupported-driver-stub.js" \
				> "$_dir/$_name/index.js"
		done
	done

	# Optional prebuilds of those drivers that yarn picked for the build host
	rm -rf node_modules/@duckdb/node-bindings* node_modules/@libsql/{darwin,linux,win32}-*

	# better-sqlite3 has to be built from source against the electron headers
	# set above, its prebuilds target the build host
	for _dir in node_modules apps/studio/node_modules; do
		[[ -d "$_dir/better-sqlite3" ]] || continue
		(cd "$_dir/better-sqlite3" && npm run build-release)
		# Its loader prefers prebuilds/ and takes this android as musl,
		# so the musl prebuild would be loaded instead of the one built here
		rm -rf "$_dir/better-sqlite3/prebuilds"
	done

	# ui-kit has to be built before the app
	yarn lib:build

	export NODE_OPTIONS="--max-old-space-size=4096"
	yarn workspace beekeeper-studio build

	# Only app.asar and the extra resources are needed from electron-builder;
	# termux_setup_electron already provides a placeholder "electron" binary
	# in $TERMUX_ELECTRON_DIST
	(
		cd apps/studio
		yarn electron-builder \
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

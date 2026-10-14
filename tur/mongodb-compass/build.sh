TERMUX_PKG_HOMEPAGE=https://www.mongodb.com/products/tools/compass
TERMUX_PKG_DESCRIPTION="The GUI for MongoDB"
# License: SSPL-1.0
TERMUX_PKG_LICENSE="custom"
TERMUX_PKG_LICENSE_FILE="LICENSE"
TERMUX_PKG_MAINTAINER="Gouranga Das Samrat <gouranga.das.khulna@gmail.com>"
TERMUX_PKG_VERSION="1.53.0"
TERMUX_PKG_SRCURL="https://github.com/mongodb-js/compass/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=31c3da98c1ec5739fc5f2e9d6a10b53beca0e809d53145f966618cfa3a472015
TERMUX_PKG_DEPENDS="electron42, krb5, libx11"
TERMUX_PKG_BUILD_DEPENDS="electron42-headers"
TERMUX_PKG_BUILD_IN_SRC=true
# Chromium/Electron don't support i686 on Linux.
TERMUX_PKG_EXCLUDED_ARCHES="i686"
TERMUX_PKG_ON_DEVICE_BUILD_NOT_SUPPORTED=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_make() {
	termux_setup_electron "$TERMUX_PKG_SRCDIR/packages/compass/package.json"

	# prebuilt addons are glibc-only, build from source
	export npm_config_build_from_source=true

	# webpack needs a big heap
	export NODE_OPTIONS="$NODE_OPTIONS --max-old-space-size=8192"

	# skip install hooks (they download a glibc-only CSFLE library)
	npm ci --ignore-scripts

	# compile workspace dependencies of mongodb-compass
	npm exec -- lerna run bootstrap \
		--scope mongodb-compass --include-dependencies --stream

	# normally done by the skipped install hook
	(cd packages/compass && node scripts/download-fonts.js)

	# webpack must resolve cpufeatures.node; optional for ssh2, so keep a placeholder if the build fails
	npm rebuild cpu-features --foreground-scripts || \
		echo "WARNING: failed to build optional native module cpu-features"
	mkdir -p node_modules/cpu-features/build/Release
	touch node_modules/cpu-features/build/Release/cpufeatures.node

	# upstream "compile" without the SBOM notices step
	HADRON_DISTRIBUTION=compass \
		npm run webpack --workspace=mongodb-compass -- --mode production

	# assemble the app like hadron-build
	local _app_dir="$TERMUX_PKG_TMPDIR/app"
	rm -rf "$_app_dir"
	mkdir -p "$_app_dir"
	cp -r packages/compass/build "$_app_dir/build"
	cp LICENSE "$_app_dir/LICENSE"

	node "$TERMUX_PKG_BUILDER_DIR/transform-package-json.js" "$_app_dir/package.json"

	(
		cd "$_app_dir"
		npm install --omit=dev --ignore-scripts --no-package-lock

		# optional at runtime (src/main/optional-deps.ts)
		# os-dns-native is not built, it doesn't compile on Android (incomplete struct __res_state)
		local _module
		for _module in \
			interruptor \
			kerberos \
			@mongodb-js/native-machine-id \
			mongodb-client-encryption; do
			npm rebuild "$_module" --foreground-scripts || \
				echo "WARNING: failed to build optional native module $_module"
		done

		find . -name node_gyp_bins -prune -exec rm -rf {} +
		find . -type d -path "*/Release/obj*" -prune -exec rm -rf {} +
	)

	local _unpack
	_unpack="$(jq -r '(["*.node", "**/vendor/**"] + .config.hadron.asar.unpack) | "{" + join(",") + "}"' \
		"$_app_dir/package.json")"

	# asar globs skip dot dirs in the path (~/.termux-build), pack from /tmp
	local _pack_dir
	_pack_dir="$(mktemp -d /tmp/mongodb-compass.XXXXXX)"
	mv "$_app_dir" "$_pack_dir/app"
	npm exec --workspace=hadron-build -- asar pack \
		"$_pack_dir/app" "$_pack_dir/app.asar" --unpack "$_unpack"
	mv "$_pack_dir"/app.asar* "$TERMUX_PKG_TMPDIR/"
	rm -rf "$_pack_dir"
}

termux_step_make_install() {
	if [[ ! -e "$TERMUX_PKG_TMPDIR/app.asar" ]]; then
		termux_error_exit "app.asar not found in $TERMUX_PKG_TMPDIR"
	fi

	local dest="$TERMUX_PREFIX/opt/mongodb-compass"
	rm -rf "$dest"
	mkdir -p "$dest/resources"
	cp -r "$TERMUX_PKG_TMPDIR"/app.asar* "$dest/resources/"

	# Install the launcher shim. See: tur/mongodb-compass/mongodb-compass-shim.sh
	sed -e "s|@TERMUX_PREFIX@|${TERMUX_PREFIX}|g" \
		"$TERMUX_PKG_BUILDER_DIR/mongodb-compass-shim.sh" \
		> "$TERMUX_PREFIX/bin/mongodb-compass"
	chmod 0755 "$TERMUX_PREFIX/bin/mongodb-compass"

	install -Dm644 packages/compass/app-icons/linux/mongodb-compass-logo-stable.png \
		"$TERMUX_PREFIX/share/pixmaps/mongodb-compass.png"

	cat > "$TERMUX_PREFIX/share/applications/mongodb-compass.desktop" <<-DESKTOP
	[Desktop Entry]
	Name=MongoDB Compass
	Comment=$TERMUX_PKG_DESCRIPTION
	Exec=$TERMUX_PREFIX/bin/mongodb-compass %U
	Icon=mongodb-compass
	Type=Application
	Categories=Development;Database;
	StartupWMClass=MongoDB Compass
	MimeType=x-scheme-handler/mongodb;x-scheme-handler/mongodb+srv;
	DESKTOP
}

termux_step_create_debscripts() {
	cat <<- EOF > postrm
	#!$TERMUX_PREFIX/bin/sh
	if [ "\$1" = "remove" ] || [ "\$1" = "purge" ]; then
		rm -rf "$TERMUX_PREFIX/opt/mongodb-compass"
	fi
	EOF
}

TERMUX_PKG_HOMEPAGE=https://desktop.turbowarp.org
TERMUX_PKG_DESCRIPTION="Scratch mod with a compiler, dark mode and a bunch of addons"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="Gouranga Das Samrat <gouranga.das.khulna@gmail.com>"
TERMUX_PKG_VERSION="1.16.0"
TERMUX_PKG_SRCURL="https://github.com/TurboWarp/desktop/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=b5a2a6b91f5c812d06aea58077bdc75c580d3ca34b813f0f8d83783d9e3a18ac
TERMUX_PKG_DEPENDS="electron42, libx11, xdg-utils"
TERMUX_PKG_BUILD_DEPENDS="electron42-headers"
TERMUX_PKG_BUILD_IN_SRC=true
# Chromium/Electron don't support i686 on Linux.
TERMUX_PKG_EXCLUDED_ARCHES="i686"
TERMUX_PKG_ON_DEVICE_BUILD_NOT_SUPPORTED=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_make() {
	termux_setup_electron "$TERMUX_PKG_SRCDIR/package.json"

	# Lifecycle scripts must run (scratch-gui generates a file webpack needs),
	# but its test-only dev dependencies must not download browsers/drivers
	PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1 CHROMEDRIVER_SKIP_DOWNLOAD=true npm ci

	# Downloads library files and the packager, and builds the extensions
	npm run fetch
	npm run webpack:prod

	# Only app.asar is needed from electron-builder; termux_setup_electron
	# already provides a placeholder "electron" binary in $TERMUX_ELECTRON_DIST
	npm exec electron-builder -- \
		--linux --"$TERMUX_ELECTRON_ARCH" --dir --publish never \
		-c.electronDist="$TERMUX_ELECTRON_DIST" \
		-c.electronVersion="$TERMUX_ELECTRON_VERSION" \
		-c.npmRebuild=false
}

termux_step_make_install() {
	local _dist_dir
	_dist_dir=$(find dist -maxdepth 1 -type d -name "*-unpacked")
	if [[ -z "$_dist_dir" || ! -e "$_dist_dir/resources/app.asar" ]]; then
		termux_error_exit "electron-builder output not found under dist"
	fi

	local dest="$TERMUX_PREFIX/opt/turbowarp"
	rm -rf "$dest"
	mkdir -p "$dest/bin"
	cp -r "$_dist_dir/resources" "$dest/resources"

	# Electron's shell.openExternal spawns "xdg-open" from PATH
	ln -sf "$TERMUX_PREFIX/bin/xdg-utils-xdg-open" "$dest/bin/xdg-open"

	# Install the launcher shim. See: x11-packages/turbowarp/turbowarp-shim.sh
	sed -e "s|@TERMUX_PREFIX@|${TERMUX_PREFIX}|g" \
		"$TERMUX_PKG_BUILDER_DIR/turbowarp-shim.sh" \
		> "$TERMUX_PREFIX/bin/turbowarp"
	chmod 0755 "$TERMUX_PREFIX/bin/turbowarp"

	install -Dm644 build/512x512.png \
		"$TERMUX_PREFIX/share/icons/hicolor/512x512/apps/org.turbowarp.TurboWarp.png"
	install -Dm644 art/icon.svg \
		"$TERMUX_PREFIX/share/icons/hicolor/scalable/apps/org.turbowarp.TurboWarp.svg"

	# Upstream's own mime definitions for .sb3/.sb2/.sb
	install -Dm644 linux-files/org.turbowarp.TurboWarp.mime.xml \
		"$TERMUX_PREFIX/share/mime/packages/org.turbowarp.TurboWarp.xml"

	# Upstream's desktop file with the Exec path pointed at the shim
	sed -e "s|^Exec=.*|Exec=$TERMUX_PREFIX/bin/turbowarp %U|" \
		-e "/^# Change the path/d" \
		linux-files/org.turbowarp.TurboWarp.desktop \
		> "$TERMUX_PREFIX/share/applications/org.turbowarp.TurboWarp.desktop"
}

termux_step_create_debscripts() {
	cat <<- EOF > postrm
	#!$TERMUX_PREFIX/bin/sh
	if [ "\$1" = "remove" ] || [ "\$1" = "purge" ]; then
		rm -rf "$TERMUX_PREFIX/opt/turbowarp"
	fi
	EOF
}

TERMUX_PKG_HOMEPAGE=https://blockbench.net
TERMUX_PKG_DESCRIPTION="Low-poly modeling and animation software"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="Gouranga Das Samrat <gouranga.das.khulna@gmail.com>"
TERMUX_PKG_VERSION="5.2.2"
TERMUX_PKG_SRCURL="https://github.com/JannisX11/blockbench/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=a87d035f8aa62130c8b4ddb686dd0c84492abc16526c44719424adb910eb3f83
TERMUX_PKG_DEPENDS="electron42, libx11, xdg-utils"
TERMUX_PKG_BUILD_DEPENDS="electron42-headers"
TERMUX_PKG_BUILD_IN_SRC=true
# Chromium/Electron don't support i686 on Linux.
TERMUX_PKG_EXCLUDED_ARCHES="i686"
TERMUX_PKG_ON_DEVICE_BUILD_NOT_SUPPORTED=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_make() {
	termux_setup_electron "$TERMUX_PKG_SRCDIR/package.json"

	npm ci --ignore-scripts
	npm run build-electron

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
	_dist_dir=$(find dist-electron -maxdepth 1 -type d -name "*-unpacked")
	if [[ -z "$_dist_dir" || ! -e "$_dist_dir/resources/app.asar" ]]; then
		termux_error_exit "electron-builder output not found under dist-electron"
	fi

	local dest="$TERMUX_PREFIX/opt/blockbench"
	rm -rf "$dest"
	mkdir -p "$dest/bin"
	cp -r "$_dist_dir/resources" "$dest/resources"

	# Electron's shell.openExternal/openPath/showItemInFolder spawn "xdg-open" from PATH
	ln -sf "$TERMUX_PREFIX/bin/xdg-utils-xdg-open" "$dest/bin/xdg-open"

	# Install the launcher shim. See: x11-packages/blockbench/blockbench-shim.sh
	sed -e "s|@TERMUX_PREFIX@|${TERMUX_PREFIX}|g" \
		"$TERMUX_PKG_BUILDER_DIR/blockbench-shim.sh" \
		> "$TERMUX_PREFIX/bin/blockbench"
	chmod 0755 "$TERMUX_PREFIX/bin/blockbench"

	install -Dm644 build/icon.png \
		"$TERMUX_PREFIX/share/icons/hicolor/1024x1024/apps/blockbench.png"
	install -Dm644 icon_full.png \
		"$TERMUX_PREFIX/share/icons/hicolor/256x256/apps/blockbench.png"

	# shared-mime-info has no entry for .bbmodel
	install -Dm644 "$TERMUX_PKG_BUILDER_DIR/blockbench.xml" \
		"$TERMUX_PREFIX/share/mime/packages/blockbench.xml"

	# File name matches desktopName in package.json
	cat > "$TERMUX_PREFIX/share/applications/net.blockbench.blockbench.desktop" <<-DESKTOP
	[Desktop Entry]
	Name=Blockbench
	Comment=$TERMUX_PKG_DESCRIPTION
	Exec=$TERMUX_PREFIX/bin/blockbench %F
	Icon=blockbench
	Type=Application
	Categories=Graphics;3DGraphics;
	StartupWMClass=Blockbench
	MimeType=model/vnd.blockbench.bbmodel;application/json;
	DESKTOP
}

termux_step_create_debscripts() {
	cat <<- EOF > postrm
	#!$TERMUX_PREFIX/bin/sh
	if [ "\$1" = "remove" ] || [ "\$1" = "purge" ]; then
		rm -rf "$TERMUX_PREFIX/opt/blockbench"
	fi
	EOF
}

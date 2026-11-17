TERMUX_PKG_HOMEPAGE=https://responsively.app
TERMUX_PKG_DESCRIPTION="Developer-friendly browser for developing responsive web apps"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="Gouranga Das Samrat <gouranga.das.khulna@gmail.com>"
TERMUX_PKG_VERSION="1.18.0"
TERMUX_PKG_SRCURL="https://github.com/responsively-org/responsively-app/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=3339f0c36d7c127c69951173dee8d1df2febd9409909a84cc7dc85578246d564
TERMUX_PKG_DEPENDS="electron42, libx11, xdg-utils"
TERMUX_PKG_BUILD_DEPENDS="electron42-headers"
TERMUX_PKG_BUILD_IN_SRC=true
# Chromium/Electron don't support i686 on Linux.
TERMUX_PKG_EXCLUDED_ARCHES="i686"
TERMUX_PKG_ON_DEVICE_BUILD_NOT_SUPPORTED=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_make() {
	termux_setup_electron "$TERMUX_PKG_SRCDIR/desktop-app/package.json"

	cd desktop-app

	# Lockfile has a react peer dependency conflict; scripts only do electron-rebuild
	npm ci --legacy-peer-deps --ignore-scripts
	(cd release/app && npm ci --legacy-peer-deps --ignore-scripts)

	# The "build" script needs yarn, so run its two halves directly
	npm run build:main
	npm run build:renderer

	# electron-builder 23 picks a different node_modules tree than npm and breaks
	# http-errors, so pack app.asar directly from release/app instead.
	rm -rf release/build
	mkdir -p release/build/app release/build/resources
	cp -r release/app/package.json release/app/dist release/app/node_modules release/build/app/
	rm -rf release/build/app/node_modules/.bin release/build/app/node_modules/.package-lock.json
	npm exec asar -- pack release/build/app release/build/resources/app.asar
	cp -r assets release/build/resources/assets
}

termux_step_make_install() {
	local _res_dir="desktop-app/release/build/resources"
	if [[ ! -e "$_res_dir/app.asar" ]]; then
		termux_error_exit "app.asar not found under $_res_dir"
	fi

	local dest="$TERMUX_PREFIX/opt/responsively"
	rm -rf "$dest"
	mkdir -p "$dest/bin"
	cp -r "$_res_dir" "$dest/resources"

	# Electron's shell.openExternal/showItemInFolder spawn "xdg-open" from PATH
	ln -sf "$TERMUX_PREFIX/bin/xdg-utils-xdg-open" "$dest/bin/xdg-open"

	# Install the launcher shim. See: x11-packages/responsively/responsively-shim.sh
	sed -e "s|@TERMUX_PREFIX@|${TERMUX_PREFIX}|g" \
		"$TERMUX_PKG_BUILDER_DIR/responsively-shim.sh" \
		> "$TERMUX_PREFIX/bin/responsively"
	chmod 0755 "$TERMUX_PREFIX/bin/responsively"

	local _size
	for _size in 16 24 32 48 64 96 128 256 512; do
		install -Dm644 "desktop-app/assets/icons/${_size}x${_size}.png" \
			"$TERMUX_PREFIX/share/icons/hicolor/${_size}x${_size}/apps/responsively.png"
	done

	cat > "$TERMUX_PREFIX/share/applications/responsively.desktop" <<-DESKTOP
	[Desktop Entry]
	Name=Responsively App
	Comment=$TERMUX_PKG_DESCRIPTION
	Exec=$TERMUX_PREFIX/bin/responsively %U
	Icon=responsively
	Type=Application
	Categories=Development;
	StartupWMClass=ResponsivelyApp
	DESKTOP
}

termux_step_create_debscripts() {
	cat <<- EOF > postrm
	#!$TERMUX_PREFIX/bin/sh
	if [ "\$1" = "remove" ] || [ "\$1" = "purge" ]; then
		rm -rf "$TERMUX_PREFIX/opt/responsively"
	fi
	EOF
}

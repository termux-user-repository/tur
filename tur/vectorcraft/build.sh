TERMUX_PKG_HOMEPAGE=https://github.com/storytold/vectorcraft
TERMUX_PKG_DESCRIPTION="An open-source, clean-room reimplementation of Adobe Illustrator in pure Rust"
TERMUX_PKG_LICENSE="MIT, Apache-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="0.8.0"
TERMUX_PKG_SRCURL="https://github.com/storytold/vectorcraft/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=53ba74fce74022496ae5e6087d1d02f51d06940b00bb5c78f13dc3b689d855fd
TERMUX_PKG_DEPENDS="libx11, libxcb, libxcursor, libxi, libxrandr, libxkbcommon, vulkan-loader-android, hicolor-icon-theme"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	termux_setup_rust

	cargo vendor
	find ./vendor \
		-mindepth 1 -maxdepth 1 -type d \
		! -wholename ./vendor/eframe \
		! -wholename ./vendor/egui-winit \
		! -wholename ./vendor/arboard \
		! -wholename ./vendor/rfd \
		! -wholename ./vendor/winit \
		! -wholename ./vendor/wgpu \
		! -wholename ./vendor/wgpu-hal \
		! -wholename ./vendor/x11rb-protocol \
		! -wholename ./vendor/xkbcommon-dl \
		! -wholename ./vendor/wayland-cursor \
		! -path './vendor/smithay-client-toolkit*' \
		-exec rm -rf '{}' \;

	patch -p1 -d vendor/wayland-cursor <"$TERMUX_PKG_BUILDER_DIR/wayland-cursor-no-shm.diff"
	for d in vendor/smithay-client-toolkit vendor/smithay-client-toolkit-*; do
		[ -f "$d/Cargo.toml" ] || continue
		[ "$(sed -n 's/^name = "\(.*\)"/\1/p' "$d/Cargo.toml" | head -n1)" = "smithay-client-toolkit" ] || continue
		case "$(sed -n 's/^version = "\(.*\)"/\1/p' "$d/Cargo.toml" | head -n1)" in
		0.19.*) patch -p1 -d "$d" <"$TERMUX_PKG_BUILDER_DIR/smithay-client-toolkit-0.19.2-no-shm.diff" ;;
		0.20.*) patch -p1 -d "$d" <"$TERMUX_PKG_BUILDER_DIR/smithay-client-toolkit-0.20.0-no-shm.diff" ;;
		esac
	done
	find vendor/eframe vendor/egui-winit vendor/arboard vendor/rfd vendor/winit \
		vendor/wgpu vendor/wgpu-hal vendor/x11rb-protocol vendor/xkbcommon-dl \
		vendor/wayland-cursor vendor/smithay-client-toolkit* -type f -print0 |
		xargs -0 sed -i \
			-e 's|"android"|"disabling_this_because_it_is_for_building_an_apk"|g' \
			-e 's|"linux"|"android"|g' \
			-e "s|libxkbcommon.so.0|libxkbcommon.so|g" \
			-e "s|libxkbcommon-x11.so.0|libxkbcommon-x11.so|g" \
			-e "s|libxcb.so.1|libxcb.so|g"

	echo "" >>Cargo.toml
	echo '[patch.crates-io]' >>Cargo.toml
	for crate in eframe egui-winit arboard rfd winit wgpu wgpu-hal x11rb-protocol xkbcommon-dl wayland-cursor; do
		echo "$crate = { path = \"./vendor/$crate\" }" >>Cargo.toml
	done
	i=0
	for d in vendor/smithay-client-toolkit vendor/smithay-client-toolkit-*; do
		[ -f "$d/Cargo.toml" ] || continue
		[ "$(sed -n 's/^name = "\(.*\)"/\1/p' "$d/Cargo.toml" | head -n1)" = "smithay-client-toolkit" ] || continue
		i=$((i + 1))
		echo "sctk_patch_$i = { path = \"./$d\", package = \"smithay-client-toolkit\" }" >>Cargo.toml
	done
}

termux_step_make() {
	termux_setup_rust

	cargo build \
		--package vectorcraft \
		--jobs "$TERMUX_PKG_MAKE_PROCESSES" \
		--target "$CARGO_TARGET_NAME" \
		--release
}

termux_step_make_install() {
	install -Dm755 \
		"target/${CARGO_TARGET_NAME}/release/vectorcraft" \
		"$TERMUX_PREFIX/bin/vectorcraft"

	install -Dm644 packaging/linux/ai.storyteller.vectorcraft.desktop \
		"$TERMUX_PREFIX/share/applications/ai.storyteller.vectorcraft.desktop"
	install -Dm644 packaging/linux/ai.storyteller.vectorcraft.mime.xml \
		"$TERMUX_PREFIX/share/mime/packages/ai.storyteller.vectorcraft.xml"
	mkdir -p "$TERMUX_PREFIX/share/icons"
	cp -R assets/app-icon/hicolor "$TERMUX_PREFIX/share/icons/"

	install -Dm644 README.md \
		"$TERMUX_PREFIX/share/doc/$TERMUX_PKG_NAME/README.md"
}

termux_step_post_make_install() {
	"$TERMUX_ELF_CLEANER" --api-level "$TERMUX_PKG_API_LEVEL" "$TERMUX_PREFIX/bin/vectorcraft"
}

termux_step_create_debscripts() {
	cat <<-EOF >postinst
		#!$TERMUX_PREFIX/bin/sh
		if command -v gtk-update-icon-cache > /dev/null 2>&1; then
			gtk-update-icon-cache -q -t -f "$TERMUX_PREFIX/share/icons/hicolor" || true
		fi
		if command -v update-desktop-database > /dev/null 2>&1; then
			update-desktop-database -q "$TERMUX_PREFIX/share/applications" || true
		fi
	EOF

	cat <<-EOF >postrm
		#!$TERMUX_PREFIX/bin/sh
		if [ "\$1" = "remove" ] || [ "\$1" = "purge" ]; then
			if command -v gtk-update-icon-cache > /dev/null 2>&1; then
				gtk-update-icon-cache -q -t -f "$TERMUX_PREFIX/share/icons/hicolor" || true
			fi
			if command -v update-desktop-database > /dev/null 2>&1; then
				update-desktop-database -q "$TERMUX_PREFIX/share/applications" || true
			fi
		fi
	EOF
}

TERMUX_PKG_HOMEPAGE=https://hnefatafl.org/
TERMUX_PKG_DESCRIPTION="Copenhagen Hnefatafl client, engine, server and artificial intelligence"
TERMUX_PKG_LICENSE="AGPL-V3"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="5.12.0-1"
TERMUX_PKG_SRCURL="https://codeberg.org/dcampbell/hnefatafl/archive/v$TERMUX_PKG_VERSION.tar.gz"
TERMUX_PKG_SHA256=b19b59e01092824dd4dd158c8469a664f4738f40feb50aa8e023913644cfa0e9
TERMUX_PKG_DEPENDS="alsa-lib, libc++, hicolor-icon-theme, libxi, libxcursor, libxrandr, hicolor-icon-theme, onnxruntime, openssl"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_HOSTBUILD=true
TERMUX_DEBUG_BUILD=true

_install_ubuntu_packages() {
	termux_download_ubuntu_packages "$@"

	export HOSTBUILD_ROOTFS="${TERMUX_PKG_HOSTBUILD_DIR}/ubuntu_packages"

	find "${HOSTBUILD_ROOTFS}" -type f -name '*.pc' | \
		xargs -n 1 sed -i -e "s|/usr|${HOSTBUILD_ROOTFS}/usr|g"

	find "${HOSTBUILD_ROOTFS}/usr/lib/x86_64-linux-gnu" -xtype l \
		-exec sh -c "ln -snvf /usr/lib/x86_64-linux-gnu/\$(readlink \$1) \$1" sh {} \;

	export LD_LIBRARY_PATH="${HOSTBUILD_ROOTFS}/usr/lib/x86_64-linux-gnu"
	LD_LIBRARY_PATH+=":${HOSTBUILD_ROOTFS}/usr/lib"

	export PKG_CONFIG_LIBDIR="${HOSTBUILD_ROOTFS}/usr/lib/x86_64-linux-gnu/pkgconfig"
	PKG_CONFIG_LIBDIR+=":/usr/lib/x86_64-linux-gnu/pkgconfig"
}

termux_step_host_build() {
	# build man page

	if [[ "$TERMUX_ON_DEVICE_BUILD" == "true" ]]; then
		return
	fi

	_install_ubuntu_packages libasound2-dev

	termux_setup_rust
	pushd "$TERMUX_PKG_SRCDIR"
	rm -f .cargo/config.toml
	cargo build \
		--jobs "$TERMUX_PKG_MAKE_PROCESSES" \
		--release \
		--examples
	cargo build \
		--jobs "$TERMUX_PKG_MAKE_PROCESSES" \
		--release
	target/release/examples/taflzero --man --username ""
	target/release/hnefatafl-client --man
	target/release/hnefatafl-server --man
	target/release/hnefatafl-server-full --man
	target/release/hnefatafl-text-protocol --man
	cp taflzero.1 "$TERMUX_PKG_HOSTBUILD_DIR"/
	cp hnefatafl-server.1 "$TERMUX_PKG_HOSTBUILD_DIR"/
	cp hnefatafl-server-full.1 "$TERMUX_PKG_HOSTBUILD_DIR"/
	cp hnefatafl-text-protocol.1 "$TERMUX_PKG_HOSTBUILD_DIR"/
	cp hnefatafl-client.1 "$TERMUX_PKG_HOSTBUILD_DIR"/
	popd
}

termux_step_pre_configure() {
	termux_setup_rust

	rm -f .cargo/config.toml

	: "${CARGO_HOME:=$HOME/.cargo}"
	export CARGO_HOME

	cargo vendor
	find ./vendor \
		-mindepth 1 -maxdepth 1 -type d \
		! -wholename ./vendor/cpal \
		! -wholename ./vendor/smithay-client-toolkit \
		! -wholename ./vendor/smithay-client-toolkit-0.19.2 \
		! -wholename ./vendor/softbuffer \
		! -wholename ./vendor/wayland-cursor \
		! -wholename ./vendor/wgpu-hal \
		! -wholename ./vendor/winit \
		! -wholename ./vendor/x11rb-protocol \
		! -wholename ./vendor/xkbcommon-dl \
		! -wholename ./vendor/rfd \
		! -wholename ./vendor/ort-sys \
		! -wholename ./vendor/cc \
		-exec rm -rf '{}' \;

	local _TAFLZERO_COMMIT=1527cb04f54c9e956b36a54822aaf75bf1ccba55
	git clone https://github.com/sovelin/taflzero.git vendor/taflzero
	git -C vendor/taflzero checkout "$_TAFLZERO_COMMIT"

	find vendor/{cpal,smithay-client-toolkit,smithay-client-toolkit-0.19.2,softbuffer,wgpu-hal,winit,x11rb-protocol,xkbcommon-dl,rfd,ort-sys} -type f | \
		xargs -n 1 sed -i \
		-e 's|target_os = "android"|target_os = "disabling_this_because_it_is_for_building_an_apk"|g' \
		-e 's|target_os = "linux"|target_os = "android"|g' \
		-e "s|libxkbcommon.so.0|libxkbcommon.so|g" \
		-e "s|libxkbcommon-x11.so.0|libxkbcommon-x11.so|g" \
		-e "s|libxcb.so.1|libxcb.so|g" \
		-e "s|/tmp|$TERMUX_PREFIX/tmp|g"

	for crate in wayland-cursor softbuffer; do
		local patch="$TERMUX_PKG_BUILDER_DIR/$crate-no-shm.diff"
		local dir="vendor/$crate"
		echo "Applying patch: $patch"
		patch -p1 -d "$dir" < "${patch}"
	done

	local patch="$TERMUX_PKG_BUILDER_DIR/smithay-client-toolkit-0.19.2-no-shm.diff"
	local dir="vendor/smithay-client-toolkit-0.19.2"
	echo "Applying patch: $patch"
	patch -p1 -d "$dir" < "${patch}"

	local patch="$TERMUX_PKG_BUILDER_DIR/smithay-client-toolkit-0.20.0-no-shm.diff"
	local dir="vendor/smithay-client-toolkit"
	echo "Applying patch: $patch"
	patch -p1 -d "$dir" < "${patch}"

	local patch="$TERMUX_PKG_BUILDER_DIR/taflzero-ort-pkgconfig.diff"
	local dir="vendor/taflzero"
	echo "Applying patch: $patch"
	patch -p1 -d "$dir" < "${patch}"

	local patch="$TERMUX_PKG_BUILDER_DIR/rust-cc-do-not-concatenate-all-the-CFLAGS.diff"
	local dir="vendor/cc"
	echo "Applying patch: $patch"
	patch -p1 -d "$dir" < "$patch"

	echo "" >> Cargo.toml
	echo '[patch.crates-io]' >> Cargo.toml
	for crate in cpal smithay-client-toolkit softbuffer wayland-cursor wgpu-hal winit x11rb-protocol xkbcommon-dl rfd ort-sys cc; do
		echo "$crate = { path = \"./vendor/$crate\" }" >> Cargo.toml
	done
	echo "smithay-client-toolkit2 = { package = \"smithay-client-toolkit\", path = \"./vendor/smithay-client-toolkit-0.19.2\" }" >> Cargo.toml
	echo "" >> Cargo.toml
	echo '[patch."git+https://github.com/sovelin/taflzero.git"]' >> Cargo.toml
	echo 'taflzero = { path = "./vendor/taflzero" }' >> Cargo.toml

	termux_download \
		"https://codeberg.org/dcampbell/hnefatafl/media/branch/main/default_nn.onnx" \
		default_nn.onnx \
		SKIP_CHECKSUM

	if [[ "$TERMUX_ON_DEVICE_BUILD" == "false" ]]; then
		HOST_TRIPLET="$(gcc -dumpmachine)"
		PKG_CONFIG_PATH_x86_64_unknown_linux_gnu="$(grep 'DefaultSearchPaths:' "/usr/share/pkgconfig/personality.d/${HOST_TRIPLET}.personality" | cut -d ' ' -f 2)"
		export PKG_CONFIG_PATH_x86_64_unknown_linux_gnu
	fi
}

termux_step_make() {
	cargo build \
		--jobs "$TERMUX_PKG_MAKE_PROCESSES" \
		--target "$CARGO_TARGET_NAME" \
		--examples
	cargo build \
		--jobs "$TERMUX_PKG_MAKE_PROCESSES" \
		--target "$CARGO_TARGET_NAME"

	if [[ "$TERMUX_ON_DEVICE_BUILD" == "true" ]]; then
		target/"$CARGO_TARGET_NAME"/debug/examples/taflzero --man --username ""
		target/"$CARGO_TARGET_NAME"/debug/hnefatafl-client --man
		target/"$CARGO_TARGET_NAME"/debug/hnefatafl-server --man
		target/"$CARGO_TARGET_NAME"/debug/hnefatafl-server-full --man
		target/"$CARGO_TARGET_NAME"/debug/hnefatafl-text-protocol --man
	else
		cp "$TERMUX_PKG_HOSTBUILD_DIR"/taflzero.1 "$TERMUX_PKG_BUILDDIR"/
		cp "$TERMUX_PKG_HOSTBUILD_DIR"/hnefatafl-server.1 "$TERMUX_PKG_BUILDDIR"/
		cp "$TERMUX_PKG_HOSTBUILD_DIR"/hnefatafl-server-full.1 "$TERMUX_PKG_BUILDDIR"/
		cp "$TERMUX_PKG_HOSTBUILD_DIR"/hnefatafl-text-protocol.1 "$TERMUX_PKG_BUILDDIR"/
		cp "$TERMUX_PKG_HOSTBUILD_DIR"/hnefatafl-client.1 "$TERMUX_PKG_BUILDDIR"/
	fi
}

termux_step_make_install() {
	install -Dm755 target/"$CARGO_TARGET_NAME"/debug/examples/taflzero -t "$TERMUX_PREFIX"/bin
	install -Dm755 target/"$CARGO_TARGET_NAME"/debug/hnefatafl-client -t "$TERMUX_PREFIX"/bin
	install -Dm755 target/"$CARGO_TARGET_NAME"/debug/hnefatafl-server -t "$TERMUX_PREFIX"/bin
	install -Dm755 target/"$CARGO_TARGET_NAME"/debug/hnefatafl-server-full -t "$TERMUX_PREFIX"/bin
	install -Dm755 target/"$CARGO_TARGET_NAME"/debug/hnefatafl-text-protocol -t "$TERMUX_PREFIX"/bin
	install -Dm644 website/src/images/helmet.svg "$TERMUX_PREFIX"/share/icons/hicolor/scalable/apps/org.hnefatafl.hnefatafl_client.svg
	install -Dm644 taflzero.1 "$TERMUX_PREFIX"/share/man/man1/taflzero.1
	install -Dm644 hnefatafl-client.1 "$TERMUX_PREFIX"/share/man/man1/hnefatafl-client.1
	install -Dm644 hnefatafl-server.1 "$TERMUX_PREFIX"/share/man/man1/hnefatafl-server.1
	install -Dm644 hnefatafl-server-full.1 "$TERMUX_PREFIX"/share/man/man1/hnefatafl-server-full.1
	install -Dm644 hnefatafl-text-protocol.1 "$TERMUX_PREFIX"/share/man/man1/hnefatafl-text-protocol.1
	install -Dm644 packages/hnefatafl-client.desktop "$TERMUX_PREFIX"/share/applications/hnefatafl-client.desktop
	install -Dm644 "default_nn.onnx" -t "$TERMUX_PREFIX"/share/taflzero
}

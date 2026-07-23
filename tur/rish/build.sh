TERMUX_PKG_HOMEPAGE=https://github.com/RikkaApps/Shizuku
TERMUX_PKG_DESCRIPTION="Rish client for Shizuku implementation"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="Nixxy-lv <nixdev888@gmail.com>"
TERMUX_PKG_VERSION=13.5.4
TERMUX_PKG_REVISION=7
TERMUX_PKG_SRCURL=https://github.com/RikkaApps/Shizuku/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=a2646e96aabda7ceb0110c34e7dbf01fe86e3a798fabdccec3b5365c800c576d
TERMUX_PKG_PLATFORM_INDEPENDENT=true

termux_step_make_host() {
	:
}

termux_step_make() {
	cd "$TERMUX_PKG_SRCDIR"

	git init
	git config user.email "builder@termux.org"
	git config user.name "Termux Builder"
	git add .
	git commit -m "Initial commit"
	git tag "v${TERMUX_PKG_VERSION}"

	rm -rf "$TERMUX_PKG_SRCDIR/api"
	git clone --depth 1 https://github.com/RikkaApps/Shizuku-API.git "$TERMUX_PKG_SRCDIR/api"

	echo "sdk.dir=$ANDROID_HOME" > local.properties
	echo "ndk.dir=$ANDROID_NDK" >> local.properties

	chmod +x gradlew
	./gradlew :manager:assembleRelease
}

termux_step_make_install() {
	mkdir -p "$TERMUX_PREFIX/bin"
	mkdir -p "$TERMUX_PREFIX/share/rish"

	cp "$TERMUX_PKG_SRCDIR/manager/src/main/assets/rish" "$TERMUX_PREFIX/bin/"

	local BUILT_APK="$TERMUX_PKG_SRCDIR/manager/build/outputs/apk/release/manager-release.apk"
	unzip -j "$BUILT_APK" "assets/rish_shizuku.dex" -d "$TERMUX_PKG_TMPDIR/"

	cp "$TERMUX_PKG_TMPDIR/rish_sh_dex" "$TERMUX_PREFIX/share/rish/rish_shizuku.dex" || cp "$TERMUX_PKG_TMPDIR/rish_shizuku.dex" "$TERMUX_PREFIX/share/rish/rish_shizuku.dex"

	sed -i 's|DEX="$BASEDIR"/rish_shizuku.dex|DEX="'"$TERMUX_PREFIX"'/share/rish/rish_shizuku.dex"|' "$TERMUX_PREFIX/bin/rish"
	sed -i 's/export RISH_APPLICATION_ID="PKG"/export RISH_APPLICATION_ID="'"$TERMUX_APP__PACKAGE_NAME"'"/' "$TERMUX_PREFIX/bin/rish"

	cat << 'EOF' > "$TERMUX_PREFIX/bin/rish.tmp"
#!/system/bin/sh
if [ ! -x /system/bin/getprop ]; then
	echo "rish: Shizuku requires a real Android environment with Android Runtime and system properties."
	exit 1
fi
EOF

	tail -n +2 "$TERMUX_PREFIX/bin/rish" >> "$TERMUX_PREFIX/bin/rish.tmp"
	mv "$TERMUX_PREFIX/bin/rish.tmp" "$TERMUX_PREFIX/bin/rish"

	chmod 755 "$TERMUX_PREFIX/bin/rish"
	chmod 400 "$TERMUX_PREFIX/share/rish/rish_shizuku.dex"
}

TERMUX_PKG_HOMEPAGE=https://github.com/coder/code-server
TERMUX_PKG_DESCRIPTION="Run VS Code on any machine anywhere and access it in the browser"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="4.127.0"
TERMUX_PKG_SRCURL=git+https://github.com/coder/code-server
TERMUX_PKG_DEPENDS="libandroid-spawn, libsecret, krb5, nodejs-24, ripgrep"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_HOSTBUILD=true
TERMUX_PKG_NO_STATICSPLIT=true
TERMUX_PKG_EXCLUDED_ARCHES="i686"
TERMUX_PKG_ON_DEVICE_BUILD_NOT_SUPPORTED=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_TAG_TYPE="latest-release-tag"
# The bundled extensions ship prebuilt binaries for other platforms
# (x86_64/musl voice, clipboard, ripgrep, etc.) that are never loaded
# on Android. They reference symbols Termux's ELF check flags as undefined, so
# acknowledge them instead of failing the build.
TERMUX_PKG_UNDEF_SYMBOLS_FILES=all

termux_step_post_get_source() {
	local f
	for f in $(cat ./patches/series); do
		echo "Applying patch: $(basename $f)"
		patch -d . -p1 < "./patches/$f";
	done

	# Ensure that code-server supports node 24
	local _node_version=$(cat .node-version | cut -d. -f1 -)
	if [ "$_node_version" != 24 ]; then
		termux_error_exit "Version mismatch: Expected 24, got $_node_version."
	fi

	# Remove `--max-old-space-size=8192` from package.json
	sed -i "s/--max-old-space-size=8192 / /g" lib/vscode/package.json

	# Remove this marker all the time
	rm -rf $TERMUX_HOSTBUILD_MARKER
}

_setup_nodejs_24() {
	local NODEJS_VERSION=24.15.0
	local NODEJS_FOLDER=${TERMUX_PKG_CACHEDIR}/build-tools/nodejs-${NODEJS_VERSION}

	if [ ! -x "$NODEJS_FOLDER/bin/node" ]; then
		mkdir -p "$NODEJS_FOLDER"
		local NODEJS_TAR_FILE=$TERMUX_PKG_TMPDIR/nodejs-$NODEJS_VERSION.tar.xz
		termux_download https://nodejs.org/dist/v${NODEJS_VERSION}/node-v${NODEJS_VERSION}-linux-x64.tar.xz \
			"$NODEJS_TAR_FILE" \
			472655581fb851559730c48763e0c9d3bc25975c59d518003fc0849d3e4ba0f6
		tar -xf "$NODEJS_TAR_FILE" -C "$NODEJS_FOLDER" --strip-components=1
	fi
	export PATH="$NODEJS_FOLDER/bin:$PATH"
}

termux_step_host_build() {
	export DISABLE_V8_COMPILE_CACHE=1
	export VERSION=$TERMUX_PKG_VERSION
	mv $TERMUX_PREFIX/bin $TERMUX_PREFIX/bin.bp
	env -i PATH="$PATH" sudo apt update
	env -i PATH="$PATH" sudo apt install -yq libxkbfile-dev libsecret-1-dev libkrb5-dev
	_setup_nodejs_24
	cd $TERMUX_PKG_SRCDIR
	npm ci
	npm install ternary-stream
	npm run build
	npm run build:vscode
	npm run release
	mv $TERMUX_PREFIX/bin.bp $TERMUX_PREFIX/bin
}

termux_step_configure() {
	_setup_nodejs_24
}

termux_step_make() {
	export DISABLE_V8_COMPILE_CACHE=1
	export VERSION=$TERMUX_PKG_VERSION
	mv $TERMUX_PREFIX/bin $TERMUX_PREFIX/bin.bp

	if [ $TERMUX_ARCH = "arm" ]; then
		export NPM_CONFIG_ARCH=armv7l
	elif [ $TERMUX_ARCH = "x86_64" ]; then
		export NPM_CONFIG_ARCH=amd64
	elif [ $TERMUX_ARCH = "aarch64" ]; then
		export NPM_CONFIG_ARCH=arm64
	else
		termux_error_exit "Unsupported arch: $TERMUX_ARCH"
	fi

	export npm_config_arch=$NPM_CONFIG_ARCH
	export npm_config_build_from_source=true

	# Create a dummy librt.so
	rm -f $TERMUX_PREFIX/lib/librt.{so,a}
	echo "INPUT(-landroid-spawn)" >> $TERMUX_PREFIX/lib/librt.so

	# Upstream removed the `release:standalone` npm script in v4.122.x. Replicate
	# the old ci/build/build-standalone-release.sh here so native modules are
	# (re)built for the target arch via `npm install`, which the new KEEP_MODULES
	# path in `npm run release` does not do.
	rsync -a release/ release-standalone
	mkdir -p release-standalone/bin release-standalone/lib
	rsync ci/build/code-server.sh release-standalone/bin/code-server
	chmod 755 release-standalone/bin/code-server
	rsync "$(node -p process.execPath)" release-standalone/lib/node
	chmod 755 release-standalone/lib/node
	export FORCE_NODE_VERSION=true
	pushd release-standalone
	npm install --unsafe-perm --omit=dev
	rm -fr ./lib/vscode/extensions/node_modules/.bin
	popd

	mv $TERMUX_PREFIX/bin.bp $TERMUX_PREFIX/bin
}

termux_step_make_install() {
	# Replace version. Upstream's build-release.sh already writes the correct
	# version into package.json, so allow the same value instead of erroring out.
	npm version --prefix release-standalone --allow-same-version "$VERSION"

	# Remove the pre-built node binary; replaced with the Termux one below.
	rm ./release-standalone/lib/node

	# Copy release files of code-server
	mkdir -p $TERMUX_PREFIX/lib/code-server
	cp -Rf ./release-standalone/* $TERMUX_PREFIX/lib/code-server/

	# Replace nodejs
	ln -sf $TERMUX_PREFIX/opt/nodejs-24/bin/node $TERMUX_PREFIX/lib/code-server/lib/node

	# Map Termux arch to the Node `process.arch` directory name that
	# @vscode/ripgrep-universal resolves at runtime (bin/<platform>-<arch>/rg).
	local _node_arch
	case $TERMUX_ARCH in
		aarch64) _node_arch=arm64 ;;
		arm) _node_arch=arm ;;
		x86_64) _node_arch=x64 ;;
		*) termux_error_exit "Unsupported arch: $TERMUX_ARCH" ;;
	esac

	# Replace ripgrep. Upstream switched from @vscode/ripgrep (single bin/rg) to
	# @vscode/ripgrep-universal (per-platform bin/<platform>-<arch>/rg) in 4.122.x.
	# A given code-server build only ever targets one platform, so every bundled
	# rg is wrong for Termux. Point them all at the Termux rg regardless of which
	# platform dir gets resolved, and add android-<arch> (process.platform is
	# "android" on Termux) which upstream does not ship.
	local _rg_bin=$TERMUX_PREFIX/lib/code-server/lib/vscode/node_modules/@vscode/ripgrep-universal/bin
	mkdir -p "$_rg_bin/android-$_node_arch"
	for _d in "$_rg_bin"/*/; do
		rm -f "${_d}rg" "${_d}rg.exe"
		ln -sf $TERMUX_PREFIX/bin/rg "${_d}rg"
	done

	# Create start script
	cat << EOF > $TERMUX_PREFIX/bin/code-server
#!$TERMUX_PREFIX/bin/env sh

exec $TERMUX_PREFIX/lib/code-server/bin/code-server "\$@"

EOF
	chmod +x $TERMUX_PREFIX/bin/code-server

	# Remove the dummy librt.so
	rm -f $TERMUX_PREFIX/lib/librt.so
}

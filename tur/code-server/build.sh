TERMUX_PKG_HOMEPAGE=https://github.com/coder/code-server
TERMUX_PKG_DESCRIPTION="Run VS Code on any machine anywhere and access it in the browser"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="4.90.2"
TERMUX_PKG_SRCURL=git+https://github.com/coder/code-server
TERMUX_PKG_DEPENDS="libandroid-spawn, libsecret, krb5, nodejs-20, ripgrep"
TERMUX_PKG_ANTI_DEPENDS="nodejs-20"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_HOSTBUILD=true
TERMUX_PKG_NO_STATICSPLIT=true
TERMUX_PKG_BLACKLISTED_ARCHES="i686"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_TAG_TYPE="latest-release-tag"

termux_step_post_get_source() {
	for f in $(cat ./patches/series); do
		echo "Applying patch: $(basename $f)"
		patch -d . -p1 < "./patches/$f";
	done

	# Ensure that code-server supports node 20
	local _node_version=$(cat .node-version | cut -d. -f1 -)
	if [ "$_node_version" != 20 ]; then
		termux_error_exit "Version mismatch: Expected 20, got $_node_version."
	fi
}

_setup_nodejs_20() {
	local NODEJS_VERSION=20.17.0
	local NODEJS_FOLDER=${TERMUX_PKG_CACHEDIR}/build-tools/nodejs-${NODEJS_VERSION}

	if [ ! -x "$NODEJS_FOLDER/bin/node" ]; then
		mkdir -p "$NODEJS_FOLDER"
		local NODEJS_TAR_FILE=$TERMUX_PKG_TMPDIR/nodejs-$NODEJS_VERSION.tar.xz
		termux_download https://nodejs.org/dist/v${NODEJS_VERSION}/node-v${NODEJS_VERSION}-linux-x64.tar.xz \
			"$NODEJS_TAR_FILE" \
			a24db3dcd151a52e75965dba04cf1b3cd579ff30d6e0af9da1aede4d0f17486b
		tar -xf "$NODEJS_TAR_FILE" -C "$NODEJS_FOLDER" --strip-components=1
	fi
	export PATH="$NODEJS_FOLDER/bin:$PATH"
}

termux_step_host_build() {
	export VERSION=$TERMUX_PKG_VERSION
	mv $TERMUX_PREFIX/bin $TERMUX_PREFIX/bin.bp
	env -i PATH="$PATH" sudo apt update
	env -i PATH="$PATH" sudo apt install -yq libxkbfile-dev libsecret-1-dev libkrb5-dev
	_setup_nodejs_20
	npm install yarn
	export PATH="$TERMUX_PKG_HOSTBUILD_DIR/node_modules/.bin:$PATH"
	cd $TERMUX_PKG_SRCDIR
	yarn --frozen-lockfile
	yarn add ternary-stream
	yarn build
	yarn build:vscode
	yarn release
	mv $TERMUX_PREFIX/bin.bp $TERMUX_PREFIX/bin
}

termux_step_configure() {
	# Remove this marker all the time
	rm -rf $TERMUX_HOSTBUILD_MARKER

	_setup_nodejs_20
	export PATH="$TERMUX_PKG_HOSTBUILD_DIR/node_modules/.bin:$PATH"
}

termux_step_make() {
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

	yarn release:standalone
	mv $TERMUX_PREFIX/bin.bp $TERMUX_PREFIX/bin
}

termux_step_make_install() {
	# Replace version
	npm version --prefix release-standalone "$VERSION"

	# Remove some pre-built binaries (currently nodejs and ripgrep) whose target is not Android
	rm ./release-standalone/lib/node
	rm ./release-standalone/lib/vscode/node_modules/@vscode/ripgrep/bin/rg

	# Copy release files of code-server
	mkdir -p $TERMUX_PREFIX/lib/code-server
	cp -Rf ./release-standalone/* $TERMUX_PREFIX/lib/code-server/

	# Replace nodejs
	ln -sf $TERMUX_PREFIX/opt/nodejs-20/bin/node $TERMUX_PREFIX/lib/code-server/lib/node

	# Replace ripgrep
	ln -sf $TERMUX_PREFIX/bin/rg $TERMUX_PREFIX/lib/code-server/lib/vscode/node_modules/@vscode/ripgrep/bin/rg

	# Create start script
	cat << EOF > $TERMUX_PREFIX/bin/code-server
#!$TERMUX_PREFIX/bin/env sh

exec $TERMUX_PREFIX/lib/code-server/bin/code-server "\$@"

EOF
	chmod +x $TERMUX_PREFIX/bin/code-server

	# Remove the dummy librt.so
	rm -f $TERMUX_PREFIX/lib/librt.so
}

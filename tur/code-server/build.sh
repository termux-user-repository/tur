TERMUX_PKG_HOMEPAGE=https://github.com/coder/code-server
TERMUX_PKG_DESCRIPTION="Run VS Code on any machine anywhere and access it in the browser"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="4.10.0"
TERMUX_PKG_SRCURL=git+https://github.com/coder/code-server
TERMUX_PKG_DEPENDS="libsecret, nodejs-16, ripgrep"
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
}

_setup_nodejs_16() {
	local NODEJS_VERSION=16.19.0
	local NODEJS_FOLDER=${TERMUX_PKG_CACHEDIR}/build-tools/nodejs-${NODEJS_VERSION}

	if [ ! -x "$NODEJS_FOLDER/bin/node" ]; then
		mkdir -p "$NODEJS_FOLDER"
		local NODEJS_TAR_FILE=$TERMUX_PKG_TMPDIR/nodejs-$NODEJS_VERSION.tar.xz
		termux_download https://nodejs.org/dist/v${NODEJS_VERSION}/node-v${NODEJS_VERSION}-linux-x64.tar.xz \
			"$NODEJS_TAR_FILE" \
			c88b52497ab38a3ddf526e5b46a41270320409109c3f74171b241132984fd08f
		tar -xf "$NODEJS_TAR_FILE" -C "$NODEJS_FOLDER" --strip-components=1
	fi
	export PATH=$NODEJS_FOLDER/bin:$PATH
}

termux_step_host_build() {
	export VERSION=$TERMUX_PKG_VERSION
	mv $TERMUX_PREFIX/bin $TERMUX_PREFIX/bin.bp
	env -i PATH="$PATH" sudo apt update
	env -i PATH="$PATH" sudo apt install -yq libxkbfile-dev libsecret-1-dev
	_setup_nodejs_16
	npm install yarn
	export PATH="$(npm bin):$PATH"
	cp -Rf $TERMUX_PKG_SRCDIR ./
	cd src
	yarn --frozen-lockfile
	yarn build
	yarn build:vscode
	yarn release
	mv $TERMUX_PREFIX/bin.bp $TERMUX_PREFIX/bin
}

termux_step_configure() {
	_setup_nodejs_16
	export PATH="$TERMUX_PKG_HOSTBUILD_DIR/node_modules/.bin:$PATH"
}

termux_step_make() {
	export VERSION=$TERMUX_PKG_VERSION
	cp -Rf $TERMUX_PKG_HOSTBUILD_DIR/src/release ./
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
	
	yarn release:standalone
	mv $TERMUX_PREFIX/bin.bp $TERMUX_PREFIX/bin
}

termux_step_make_install() {
	# Remove some pre-built binaries (currently nodejs and ripgrep) whose target is not Android
	rm ./release-standalone/lib/node
	rm ./release-standalone/lib/vscode/node_modules/@vscode/ripgrep/bin/rg

	# Copy release files of code-server
	mkdir -p $TERMUX_PREFIX/lib/code-server
	cp -Rf ./release-standalone/* $TERMUX_PREFIX/lib/code-server/

	# Replace nodejs
	ln -sf $TERMUX_PREFIX/opt/nodejs-16/bin/node $TERMUX_PREFIX/lib/code-server/lib/node

	# Replace ripgrep
	ln -sf $TERMUX_PREFIX/bin/rg $TERMUX_PREFIX/lib/code-server/lib/vscode/node_modules/@vscode/ripgrep/bin/rg

	# Create start script
	cat << EOF > $TERMUX_PREFIX/bin/code-server
#!$TERMUX_PREFIX/bin/env sh

exec $TERMUX_PREFIX/lib/code-server/bin/code-server "\$@"

EOF
	chmod +x $TERMUX_PREFIX/bin/code-server
}

TERMUX_PKG_HOMEPAGE=https://github.com/coder/code-server
TERMUX_PKG_DESCRIPTION="Run VS Code on any machine anywhere and access it in the browser"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=4.8.3
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=https://github.com/coder/code-server.git
TERMUX_PKG_DEPENDS="libsecret, nodejs-lts, ripgrep"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_HOSTBUILD=true
TERMUX_PKG_NO_STATICSPLIT=true
TERMUX_PKG_BLACKLISTED_ARCHES="i686"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_TAG_TYPE="latest-release-tag"

termux_step_host_build() {
	export VERSION=$TERMUX_PKG_VERSION
	mv $TERMUX_PREFIX/bin $TERMUX_PREFIX/bin.bp
	env -i PATH="$PATH" sudo apt update
	env -i PATH="$PATH" sudo apt install -yq libxkbfile-dev libsecret-1-dev
	termux_setup_nodejs
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
	termux_setup_nodejs
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
	ln -sf $TERMUX_PREFIX/bin/node $TERMUX_PREFIX/lib/code-server/lib/node

	# Replace ripgrep
	ln -sf $TERMUX_PREFIX/bin/rg $TERMUX_PREFIX/lib/code-server/lib/vscode/node_modules/@vscode/ripgrep/bin/rg

	# Create start script
	cat << EOF > $TERMUX_PREFIX/bin/code-server
#!$TERMUX_PREFIX/bin/env sh

exec $TERMUX_PREFIX/lib/code-server/bin/code-server "\$@"

EOF
	chmod +x $TERMUX_PREFIX/bin/code-server
}

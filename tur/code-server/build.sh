TERMUX_PKG_HOMEPAGE=https://github.com/coder/code-server
TERMUX_PKG_DESCRIPTION="Run VS Code on any machine anywhere and access it in the browser"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=(4.8.3)
TERMUX_PKG_VERSION+=(1.72.1)
TERMUX_PKG_SRCURL=(https://github.com/coder/code-server/archive/refs/tags/v${TERMUX_PKG_VERSION[0]}.tar.gz)
TERMUX_PKG_SRCURL+=(https://github.com/microsoft/vscode/archive/refs/tags/${TERMUX_PKG_VERSION[1]}.tar.gz)
TERMUX_PKG_SHA256=(625fcd13463adb8514395bf0329d4c8aac9e108b98d1f8006d3eb8e8026b4f61)
TERMUX_PKG_SHA256+=(203af193854b6117fce904d78e9506cdf384dcd594097fd35264c1a5513b7c4e)
TERMUX_PKG_DEPENDS="libsecret, nodejs-lts"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_HOSTBUILD=true
TERMUX_PKG_NO_STATICSPLIT=true
TERMUX_PKG_BLACKLISTED_ARCHES="i686"

VSCODE_DISTRO_COMMIT=129500ee4c8ab7263461ffe327268ba56b9f210d

termux_step_post_get_source() {
	rm -r lib/vscode
	mv vscode-${TERMUX_PKG_VERSION[1]} lib/vscode
	for f in $(cat ./patches/series); do
		echo "Applying patch: $(basename $f)"
		patch -d . -p1 < "./patches/$f";
	done
}

termux_step_host_build() {
	mv $TERMUX_PREFIX/bin $TERMUX_PREFIX/bin.bp
	export VSCODE_DISTRO_COMMIT
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
	export VSCODE_DISTRO_COMMIT
}

termux_step_make() {
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
	# TODO: Replace ./lib/vscode/node_modules/@vscode/ripgrep/bin/rg
	rm ./release-standalone/lib/node
	mkdir -p $TERMUX_PREFIX/lib/code-server
	cp -Rf ./release-standalone/* $TERMUX_PREFIX/lib/code-server/
	cat << EOF > $TERMUX_PREFIX/bin/code-server
#!$TERMUX_PREFIX/bin/env sh

exec $TERMUX_PREFIX/lib/code-server/bin/code-server "\$@"

EOF
	chmod +x $TERMUX_PREFIX/bin/code-server
	ln -sfr $TERMUX_PREFIX/bin/node $TERMUX_PREFIX/lib/code-server/lib/node
}

TERMUX_PKG_HOMEPAGE=https://github.com/microsoft/vscode
TERMUX_PKG_DESCRIPTION="Visual Studio Code"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="1.77.3"
TERMUX_PKG_SRCURL=git+https://github.com/microsoft/vscode
TERMUX_PKG_GIT_BRANCH="$TERMUX_PKG_VERSION"
TERMUX_PKG_DEPENDS="electron-deps, libx11, libxkbfile, libsecret, ripgrep"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_NO_STATICSPLIT=true
TERMUX_PKG_HOSTBUILD=true
# Chromium doesn't support i686 on Linux.
TERMUX_PKG_BLACKLISTED_ARCHES="i686"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_TAG_TYPE="latest-release-tag"

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

termux_step_post_get_source() {
	# Parse yarn.lock and get native-keymap verion
	python3 -m venv $TERMUX_PKG_CACHEDIR/venv-dir
	(. $TERMUX_PKG_CACHEDIR/venv-dir/bin/activate
	python3 -m pip install pyarn
	python3 $TERMUX_PKG_BUILDER_DIR/get-version-from-yarn-v1-lockfile.py native-keymap $TERMUX_PKG_SRCDIR/yarn.lock > $TERMUX_PKG_TMPDIR/_native_keymap_verion_info.json)

	# Use custom node-native-keymap
	local _native_keymap_verion="$(jq -r '.version' $TERMUX_PKG_TMPDIR/_native_keymap_verion_info.json)"
	local _native_keymap_src_url="$(jq -r '.url' $TERMUX_PKG_TMPDIR/_native_keymap_verion_info.json)"
	local _native_keymap_sha256sum="SKIP_CHECKSUM"
	local _native_keymap_path="$TERMUX_PKG_CACHEDIR/$(basename $_native_keymap_src_url)"
	termux_download $_native_keymap_src_url $_native_keymap_path $_native_keymap_sha256sum
	mkdir -p $TERMUX_PKG_SRCDIR/node-native-keymap-src
	tar -xf $_native_keymap_path -C $TERMUX_PKG_SRCDIR/node-native-keymap-src --strip-components=1
}

termux_step_host_build() {
	if [ -e "$TERMUX_PREFIX/bin" ]; then
		rm -rf $TERMUX_PREFIX/bin.bp
		mv -f $TERMUX_PREFIX/bin $TERMUX_PREFIX/bin.bp
	fi
	_setup_nodejs_16
	npm install yarn
	export PATH="$(npm bin):$PATH"
	if [ -e "$TERMUX_PREFIX/bin.bp" ]; then
		rm -rf $TERMUX_PREFIX/bin
		mv -f $TERMUX_PREFIX/bin.bp $TERMUX_PREFIX/bin
	fi
}

termux_step_configure() {
	_setup_nodejs_16
	export PATH="$TERMUX_PKG_HOSTBUILD_DIR/node_modules/.bin:$PATH"
}

termux_step_make() {
	if [ -e "$TERMUX_PREFIX/bin" ]; then
		rm -rf $TERMUX_PREFIX/bin.bp
		mv -f $TERMUX_PREFIX/bin $TERMUX_PREFIX/bin.bp
	fi

	if [ $TERMUX_ARCH = "arm" ]; then
		export NPM_CONFIG_ARCH=arm
		CODE_ARCH=armhf
		ELECTRON_ARCH=armv7l
	elif [ $TERMUX_ARCH = "x86_64" ]; then
		export NPM_CONFIG_ARCH=x64
		CODE_ARCH=x64
		ELECTRON_ARCH=x64
	elif [ $TERMUX_ARCH = "aarch64" ]; then
		export NPM_CONFIG_ARCH=arm64
		CODE_ARCH=arm64
		ELECTRON_ARCH=arm64
	else
		termux_error_exit "Unsupported arch: $TERMUX_ARCH"
	fi
	export npm_config_arch=$NPM_CONFIG_ARCH

	export CXX="$CXX -v -L$TERMUX_PREFIX/lib"

	yarn
	yarn run gulp vscode-linux-$CODE_ARCH-min

	if [ -e "$TERMUX_PREFIX/bin.bp" ]; then
		rm -rf $TERMUX_PREFIX/bin
		mv -f $TERMUX_PREFIX/bin.bp $TERMUX_PREFIX/bin
	fi
}

termux_step_make_install() {
	mkdir -p $TERMUX_PREFIX/lib/code-oss

	# Download the pre-built electron compiled for Termux
	local _electron_verion="$(jq -r '.devDependencies.electron' $TERMUX_PKG_SRCDIR/package.json)"
	local _electron_archive_url=https://github.com/termux-user-repository/electron-tur-builder/releases/download/v$_electron_verion/electron-v$_electron_verion-linux-$ELECTRON_ARCH.zip
	local _electron_archive_path="$TERMUX_PKG_CACHEDIR/$(basename $_electron_archive_url)"
	termux_download $_electron_archive_url $_electron_archive_path SKIP_CHECKSUM

	# Unzip the pre-built electron
	unzip $_electron_archive_path -d $TERMUX_PREFIX/lib/code-oss

	# Rename the binary file
	mv $TERMUX_PREFIX/lib/code-oss/electron $TERMUX_PREFIX/lib/code-oss/code-oss

	# Remove the default resources
	rm -rf $TERMUX_PREFIX/lib/code-oss/resources/*

	# Copy resources
	cp -r --no-preserve=ownership --preserve=mode ../VSCode-linux-$CODE_ARCH/resources/* $TERMUX_PREFIX/lib/code-oss/resources/

	# Install the start script
	mkdir -p $TERMUX_PREFIX/lib/code-oss/bin
	cp ../VSCode-linux-$CODE_ARCH/bin/code-oss $TERMUX_PREFIX/lib/code-oss/bin/code-oss
	sed -i "s|/usr/bin|$TERMUX_PREFIX/bin|g
			s|/usr/share/code-oss|$TERMUX_PREFIX/lib/code-oss|g
			s|/proc/version|/dev/null|g" $TERMUX_PREFIX/lib/code-oss/bin/code-oss
	chmod +x $TERMUX_PREFIX/lib/code-oss/bin/code-oss

	# Replace ripgrep
	ln -sfr $TERMUX_PREFIX/bin/rg $TERMUX_PREFIX/lib/code-oss/resources/app/node_modules.asar.unpacked/@vscode/ripgrep/bin/rg

	# Install appdata and desktop file
	sed -i "s|@@NAME_SHORT@@|Code|g
			s|@@NAME_LONG@@|Code - OSS|g
			s|@@NAME@@|code-oss|g
			s|@@ICON@@|com.visualstudio.code.oss|g
			s|@@EXEC@@|$TERMUX_PREFIX/bin/code-oss|g
			s|@@LICENSE@@|MIT|g" resources/linux/code{.appdata.xml,-workspace.xml,.desktop,-url-handler.desktop}
	install -Dm600 resources/linux/code.appdata.xml $TERMUX_PREFIX/share/metainfo/code-oss.appdata.xml
	install -Dm600 resources/linux/code-workspace.xml $TERMUX_PREFIX/share/mime/packages/code-oss.workspace.xml
	install -Dm600 resources/linux/code.desktop $TERMUX_PREFIX/share/applications/code-oss.desktop
	install -Dm600 resources/linux/code-url-handler.desktop $TERMUX_PREFIX/share/applications/code-oss-url-handler.desktop
	install -Dm600 ../VSCode-linux-$CODE_ARCH/resources/app/resources/linux/code.png $TERMUX_PREFIX/share/pixmaps/com.visualstudio.code.oss.png

	# Install binaries to $PREFIX/bin
	ln -sfr $TERMUX_PREFIX/lib/code-oss/bin/code-oss $TERMUX_PREFIX/bin/code-oss
	ln -sfr $TERMUX_PREFIX/bin/code-oss $TERMUX_PREFIX/bin/code
	ln -sfr $TERMUX_PREFIX/bin/code-oss $TERMUX_PREFIX/bin/vscode

	# Install shell completions
	cp resources/completions/bash/code resources/completions/bash/code-oss
	cp resources/completions/bash/code resources/completions/bash/vscode
	cp resources/completions/zsh/_code resources/completions/zsh/_code-oss
	cp resources/completions/zsh/_code resources/completions/zsh/_vscode
	sed -i 's|@@APPNAME@@|code|g' resources/completions/{bash/code,zsh/_code}
	sed -i 's|@@APPNAME@@|vscode|g' resources/completions/{bash/vscode,zsh/_vscode}
	sed -i 's|@@APPNAME@@|code-oss|g' resources/completions/{bash/code-oss,zsh/_code-oss}
	install -Dm600 resources/completions/bash/code $TERMUX_PREFIX/share/bash-completion/completions/code
	install -Dm600 resources/completions/zsh/_code $TERMUX_PREFIX/share/zsh/site-functions/_code
	install -Dm600 resources/completions/bash/vscode $TERMUX_PREFIX/share/bash-completion/completions/vscode
	install -Dm600 resources/completions/zsh/_vscode $TERMUX_PREFIX/share/zsh/site-functions/_vscode
	install -Dm600 resources/completions/bash/code-oss $TERMUX_PREFIX/share/bash-completion/completions/code-oss
	install -Dm600 resources/completions/zsh/_code-oss $TERMUX_PREFIX/share/zsh/site-functions/_code-oss

	# Install license files
	mkdir -p $TERMUX_PREFIX/share/doc/code-oss
	cp ../VSCode-linux-$CODE_ARCH/resources/app/LICENSE.txt $TERMUX_PREFIX/share/doc/code-oss/LICENSE
	cp ../VSCode-linux-$CODE_ARCH/resources/app/ThirdPartyNotices.txt $TERMUX_PREFIX/share/doc/code-oss/ThirdPartyNotices.txt
}

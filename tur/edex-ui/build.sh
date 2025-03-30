TERMUX_PKG_HOMEPAGE=https://github.com/GitSquared/edex-ui
TERMUX_PKG_DESCRIPTION="A cross-platform, customizable science fiction terminal emulator with advanced monitoring & touchscreen support"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="2.2.8"
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=git+https://github.com/GitSquared/edex-ui
TERMUX_PKG_SHA256=c6a8ef34890c028ee2a1e4c64485db29d4d0aedda0d63c0fc5f8572d45226b51
TERMUX_PKG_DEPENDS="electron-deps"
TERMUX_PKG_ANTI_BUILD_DEPENDS="electron-deps"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_NO_STATICSPLIT=true

termux_step_get_source() {
	local TMP_CHECKOUT=$TERMUX_PKG_CACHEDIR/tmp-checkout
	local TMP_CHECKOUT_VERSION=$TERMUX_PKG_CACHEDIR/tmp-checkout-version

	if [ ! -f $TMP_CHECKOUT_VERSION ] || [ "$(cat $TMP_CHECKOUT_VERSION)" != "$TERMUX_PKG_VERSION" ]; then
		if [ "$TERMUX_PKG_GIT_BRANCH" == "" ]; then
			TERMUX_PKG_GIT_BRANCH=v$TERMUX_PKG_VERSION
		fi

		rm -rf $TMP_CHECKOUT
		git clone --depth 1 \
			--branch $TERMUX_PKG_GIT_BRANCH \
			${TERMUX_PKG_SRCURL:4} \
			$TMP_CHECKOUT

		# Set git submoudle url to https rather than ssh
		sed -i 's|git@github.com:|https://github.com/|g' $TMP_CHECKOUT/.gitmodules

		pushd $TMP_CHECKOUT
		git submodule update --init --recursive --depth=1
		popd

		echo "$TERMUX_PKG_VERSION" > $TMP_CHECKOUT_VERSION
	fi

	rm -rf $TERMUX_PKG_SRCDIR
	cp -Rf $TMP_CHECKOUT $TERMUX_PKG_SRCDIR
}

__tur_setup_nodejs_14() {
	local NODEJS_VERSION=14.2.0
	local NODEJS_FOLDER=${TERMUX_PKG_CACHEDIR}/build-tools/nodejs-${NODEJS_VERSION}

	if [ ! -x "$NODEJS_FOLDER/bin/node" ]; then
		mkdir -p "$NODEJS_FOLDER"
		local NODEJS_TAR_FILE=$TERMUX_PKG_TMPDIR/nodejs-$NODEJS_VERSION.tar.xz
		termux_download https://nodejs.org/dist/v${NODEJS_VERSION}/node-v${NODEJS_VERSION}-linux-x64.tar.xz \
			"$NODEJS_TAR_FILE" \
			468cbd92271da8c0cacaa3fa432a73a332e398bade8ad7359a94aa8ab3cc3cca
		tar -xf "$NODEJS_TAR_FILE" -C "$NODEJS_FOLDER" --strip-components=1
	fi
	export PATH="$NODEJS_FOLDER/bin:$PATH"
}

__tur_setup_pypy2() {
	termux_download \
		https://downloads.python.org/pypy/pypy2.7-v7.3.17-linux64.tar.bz2 \
		"$TERMUX_PKG_CACHEDIR"/pypy2.7-v7.3.17-linux64.tar.bz2 \
		9f3497f87b3372d17e447369e0016a4bec99a6b4d2a59aba774a25bfe4353474
	tar -C "$TERMUX_PKG_CACHEDIR" -xf "$TERMUX_PKG_CACHEDIR"/pypy2.7-v7.3.17-linux64.tar.bz2
	export PATH="$TERMUX_PKG_CACHEDIR/pypy2.7-v7.3.17-linux64/bin:$PATH"
}

termux_step_configure() {
	__tur_setup_nodejs_14
	__tur_setup_pypy2

	if [ $TERMUX_ARCH = "arm" ]; then
		electron_arch="armv7l"
		export npm_config_force_process_config="true"
		export npm_config_arch=arm
	elif [ $TERMUX_ARCH = "x86_64" ]; then
		electron_arch="x64"
		export npm_config_arch=x64
	elif [ $TERMUX_ARCH = "aarch64" ]; then
		electron_arch="arm64"
		export npm_config_force_process_config="true"
		export npm_config_arch=arm64
	elif [ $TERMUX_ARCH = "i686" ]; then
		electron_arch="ia32"
		export npm_config_force_process_config="true"
		export npm_config_arch=ia32
	fi
	export NPM_CONFIG_ARCH=$npm_config_arch

	# Download the pre-built electron compiled for Termux
	local _electron_verion="$(jq -r '.dependencies.electron' $TERMUX_PKG_SRCDIR/package.json)"
	_electron_verion="${_electron_verion#^}"
	local _electron_archive_url=https://github.com/termux-user-repository/electron-tur-builder/releases/download/v$_electron_verion/electron-v$_electron_verion-linux-$electron_arch.zip
	local _electron_archive_path="$TERMUX_PREFIX/tmp/$(basename $_electron_archive_url)"
	termux_download $_electron_archive_url $_electron_archive_path SKIP_CHECKSUM
	mkdir -p $TERMUX_PREFIX/tmp/custom-electron-dist
	unzip $_electron_archive_path -d $TERMUX_PREFIX/tmp/custom-electron-dist
}

termux_step_make() {
	npm install
	npm run prebuild-linux
	./node_modules/.bin/electron-builder build -l --$electron_arch
}

termux_step_make_install() {
	local _dist_path=linux-$electron_arch-unpacked
	if [ $TERMUX_ARCH = "x86_64" ]; then
		_dist_path=linux-unpacked
	fi
	mv dist/$_dist_path $TERMUX_PREFIX/lib/edex-ui
	# FIXME: This is a temporary fix. It should be done in electron.
	patch -p0 -d $TERMUX_PREFIX/lib/edex-ui < $TERMUX_PKG_BUILDER_DIR/9999-fix-for-isexe.diff
	ln -sfr $TERMUX_PREFIX/lib/edex-ui/edex-ui $TERMUX_PREFIX/bin
}

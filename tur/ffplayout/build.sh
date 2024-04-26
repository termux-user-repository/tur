TERMUX_PKG_HOMEPAGE=https://ffplayout.github.io
TERMUX_PKG_DESCRIPTION="Rust and ffmpeg based playout"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="0.21.4"
TERMUX_PKG_SRCURL=git+https://github.com/ffplayout/ffplayout
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_TAG_TYPE="latest-release-tag"
TERMUX_PKG_HOSTBUILD=true

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

termux_step_post_get_source() {
	# Remove this marker all the time
	rm -rf $TERMUX_HOSTBUILD_MARKER
}

termux_step_host_build() {
	termux_setup_nodejs
	pushd $TERMUX_PKG_SRCDIR
	bash ./scripts/man_create.sh
	rm -rf public
	cd ffplayout-frontend
	npm install
	npm run generate
	cp -r .output/public ../public
	popd
}

termux_step_make() {
	termux_setup_rust

	if [ "$TERMUX_ARCH" == "x86_64" ]; then
		local libdir=target/x86_64-linux-android/release/deps
		mkdir -p $libdir
		pushd $libdir
		RUSTFLAGS+=" -C link-arg=$($CC -print-libgcc-file-name)"
		echo "INPUT(-l:libunwind.a)" > libgcc.so
		popd
	fi

	cargo build --jobs $TERMUX_MAKE_PROCESSES --release --target $CARGO_TARGET_NAME
}

termux_step_make_install() {
	cp ./target/$CARGO_TARGET_NAME/release/ffpapi .
	cp ./target/$CARGO_TARGET_NAME/release/ffplayout .
	tar -cvf "ffplayout-v${TERMUX_PKG_VERSION}_${CARGO_TARGET_NAME}.tar" --exclude='*.db' --exclude='*.db-shm' --exclude='*.db-wal' assets docker docs public LICENSE README.md CHANGELOG.md ffplayout ffpapi
	mkdir -p $TERMUX_PREFIX/opt/ffplayout
	tar -C $TERMUX_PREFIX/opt/ffplayout -xvf "ffplayout-v${TERMUX_PKG_VERSION}_${CARGO_TARGET_NAME}.tar"
	ln -sfr $TERMUX_PREFIX/opt/ffplayout/ffpapi $TERMUX_PREFIX/bin
	ln -sfr $TERMUX_PREFIX/opt/ffplayout/ffplayout $TERMUX_PREFIX/bin
}

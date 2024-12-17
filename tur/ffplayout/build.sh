TERMUX_PKG_HOMEPAGE=https://ffplayout.github.io
TERMUX_PKG_DESCRIPTION="Rust and ffmpeg based playout"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="0.24.4"
TERMUX_PKG_SRCURL=git+https://github.com/ffplayout/ffplayout
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_TAG_TYPE="latest-release-tag"
TERMUX_PKG_HOSTBUILD=true

termux_step_post_get_source() {
	# Remove this marker all the time
	rm -rf $TERMUX_HOSTBUILD_MARKER
}

termux_step_host_build() {
	termux_setup_nodejs
	pushd $TERMUX_PKG_SRCDIR
	bash ./scripts/man_create.sh
	rm -rf public
	cd frontend
	npm install
	npm run generate
	cp -r .output/public ../public
	popd
}

termux_step_make() {
	termux_setup_rust

	unset CFLAGS

	if [ "$TERMUX_ARCH" == "x86_64" ]; then
		local env_host=$(printf $CARGO_TARGET_NAME | tr a-z A-Z | sed s/-/_/g)
		export CARGO_TARGET_${env_host}_RUSTFLAGS+=" -C link-arg=$($CC -print-libgcc-file-name)"
	fi

	cargo build --jobs $TERMUX_PKG_MAKE_PROCESSES --release --target $CARGO_TARGET_NAME
}

termux_step_make_install() {
	cp ./target/$CARGO_TARGET_NAME/release/ffplayout .
	tar -cvf "ffplayout-v${TERMUX_PKG_VERSION}_${CARGO_TARGET_NAME}.tar" --exclude='*.db' --exclude='*.db-shm' --exclude='*.db-wal' assets docker docs LICENSE README.md CHANGELOG.md ffplayout
	mkdir -p $TERMUX_PREFIX/opt/ffplayout
	tar -C $TERMUX_PREFIX/opt/ffplayout -xvf "ffplayout-v${TERMUX_PKG_VERSION}_${CARGO_TARGET_NAME}.tar"
	ln -sfr $TERMUX_PREFIX/opt/ffplayout/ffpapi $TERMUX_PREFIX/bin
	ln -sfr $TERMUX_PREFIX/opt/ffplayout/ffplayout $TERMUX_PREFIX/bin
}

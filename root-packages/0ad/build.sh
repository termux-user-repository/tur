TERMUX_PKG_HOMEPAGE=https://play0ad.com/
TERMUX_PKG_DESCRIPTION="Free, open-source, historical RTS game of ancient warfare"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@IntinteDAO"
TERMUX_PKG_VERSION=0.28.0
TERMUX_PKG_SRCURL=(https://releases.wildfiregames.com/0ad-${TERMUX_PKG_VERSION}-unix-build.tar.xz
                  https://releases.wildfiregames.com/0ad-${TERMUX_PKG_VERSION}-unix-data.tar.xz)
TERMUX_PKG_SHA256=(27e217755ef76a922fe58dbf593d96e54b6ed2375d23f548c35619aa6bd5a42a
                   e844b30ae2102c47e0a4fff2f0e0ef05ba0cebb1890aa72276fa12457c39526f)
TERMUX_PKG_DEPENDS="0ad-data, boost, curl, glew, libglvnd, libicu, libnspr, libxml2, miniupnpc, openal-soft, sdl2, zlib, libenet, libvorbis, libogg, libpng, libsodium, fmt, gloox"
TERMUX_PKG_GROUPS="games"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_HOSTBUILD=true

termux_step_host_build() {
	local PREMAKE_SRC=$TERMUX_PKG_SRCDIR/libraries/source/premake-core
	local PV=5.0.0-beta8
	mkdir -p "$PREMAKE_SRC"
	cd "$PREMAKE_SRC"
	termux_download "https://github.com/premake/premake-core/archive/refs/tags/v${PV}.tar.gz" \
		"v${PV}.tar.gz" \
		2a55195fd2b27e5aa3de8ff6d22cdb127232a86f801d06e7f673d30a0eba09ac
	tar -xf "v${PV}.tar.gz" --strip-components=1
	env -i PATH="$PATH" HOME="$HOME" CC=gcc make -f Bootstrap.mak linux

	mkdir -p "$TERMUX_PKG_HOSTBUILD_DIR/bin"
	cp bin/release/premake5 "$TERMUX_PKG_HOSTBUILD_DIR/bin/premake5"
}

termux_step_post_get_source() {
	local FCOLLADA_BASE="libraries/source/fcollada"
	mkdir -p "$FCOLLADA_BASE"
	if [ ! -f "$FCOLLADA_BASE/fcollada-28209.tar.xz" ]; then
		tar -xf "$TERMUX_PKG_SRCDIR/../0ad-${TERMUX_PKG_VERSION}-unix-build.tar.xz" -O "0ad-${TERMUX_PKG_VERSION}/libraries/source/fcollada/fcollada-28209.tar.xz" > "$FCOLLADA_BASE/fcollada-28209.tar.xz" || true
	fi

	tar -xf "$TERMUX_PKG_CACHEDIR/0ad-${TERMUX_PKG_VERSION}-unix-data.tar.xz" -C "$TERMUX_PKG_SRCDIR" --strip-components=1

	# Copy localized SpiderMonkey patches
	cp "$TERMUX_PKG_BUILDER_DIR"/spidermonkey-patches/*.patch libraries/source/spidermonkey/patches/


	cat <<- 'EOF' > "$FCOLLADA_BASE/build.sh"
		#!/bin/sh
		set -e
		PV=28209
		cd "$(dirname "$0")"
		if [ ! -d "fcollada-$PV" ]; then
		    tar -xf fcollada-$PV.tar.xz
		fi
		(cd fcollada-$PV && ./build.sh)
		rm -rf include lib
		cp -R fcollada-$PV/include fcollada-$PV/lib .
		echo "$PV+wfg1" > .already-built
	EOF
	chmod +x "$FCOLLADA_BASE/build.sh"
}

termux_step_pre_configure() {
	termux_setup_rust

	cargo install cbindgen

	if [ "$TERMUX_DEBUG_BUILD" = false ]; then
		local env_host=$(printf $CARGO_TARGET_NAME | tr a-z A-Z | sed s/-/_/g)
		export CARGO_TARGET_${env_host}_RUSTFLAGS+=" -C debuginfo=1"
	fi

	export BINDGEN_CFLAGS="--target=$CCTERMUX_HOST_PLATFORM --sysroot=$TERMUX_STANDALONE_TOOLCHAIN/sysroot -D_FORTIFY_SOURCE=0"
	local env_name=BINDGEN_EXTRA_CLANG_ARGS_${CARGO_TARGET_NAME@U}
	env_name=${env_name//-/_}
	export $env_name="$BINDGEN_CFLAGS"

	export HOST_CC=$(command -v clang)
	export HOST_CXX=$(command -v clang++)

	cat >> libraries/source/spidermonkey/mozconfig <<EOF
ac_add_options --target=$TERMUX_HOST_PLATFORM
ac_add_options --host=$TERMUX_BUILD_TUPLE
ac_add_options --custom-rust-target-triple=$CARGO_TARGET_NAME
ac_add_options --prefix=$TERMUX_PREFIX
ac_add_options --with-sysroot=$TERMUX_PREFIX
EOF

	export PATH="$TERMUX_PKG_HOSTBUILD_DIR/bin:$PATH"
	if [ ! -f "$TERMUX_PKG_HOSTBUILD_DIR/bin/premake5" ]; then
		echo "ERROR: premake5 not found in $TERMUX_PKG_HOSTBUILD_DIR/bin"
		ls -R "$TERMUX_PKG_HOSTBUILD_DIR"
		exit 1
	fi
	cd $TERMUX_PKG_SRCDIR/libraries
	./build-source-libs.sh --without-nvtt --with-system-premake -j${TERMUX_PKG_MAKE_PROCESSES}
	export LDFLAGS+=" -L$TERMUX_PREFIX/lib -liconv -llog -lgloox -Wl,--no-as-needed,-lOpenSLES,--as-needed -Wl,-rpath=$TERMUX_PREFIX/lib/0ad"
	export CXXFLAGS+=" -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=0 -D_GNU_SOURCE -DCONFIG_ENABLE_MOCKS=0 -U__ANDROID__ -D_LIBCPP_HAS_NO_C11_ALIGNED_ALLOC -DINSTALLED_DATADIR=\"$TERMUX_PREFIX/share/0ad\""
	export CFLAGS+=" -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=0"

	cd $TERMUX_PKG_SRCDIR/build/workspaces
	./update-workspaces.sh --with-system-premake5 --without-nvtt --without-atlas --without-tests -j${TERMUX_PKG_MAKE_PROCESSES}
}

termux_step_configure() {
	:
}

termux_step_make() {
	cd $TERMUX_PKG_SRCDIR/build/workspaces/gcc
	make -j$TERMUX_PKG_MAKE_PROCESSES pyrogenesis CC="$CC" CXX="$CXX" LD="$CC" LDFLAGS="${LDFLAGS}"
}

termux_step_make_install() {
	mkdir -p $TERMUX_PREFIX/bin
	cp $TERMUX_PKG_SRCDIR/binaries/system/pyrogenesis $TERMUX_PREFIX/bin/pyrogenesis

	# Isolate 0AD shared libraries into their own directory
	mkdir -p $TERMUX_PREFIX/lib/0ad
	[ -f "$TERMUX_PKG_SRCDIR/binaries/system/libCollada.so" ] && install -Dm755 $TERMUX_PKG_SRCDIR/binaries/system/libCollada.so $TERMUX_PREFIX/lib/0ad/libCollada.so

	# Install internally built Spidermonkey library
	[ -f "$TERMUX_PKG_SRCDIR/binaries/system/libmozjs128-release.so" ] && install -Dm755 $TERMUX_PKG_SRCDIR/binaries/system/libmozjs128-release.so $TERMUX_PREFIX/lib/0ad/libmozjs128-release.so

	# Install desktop resources
	install -Dm644 $TERMUX_PKG_SRCDIR/build/resources/0ad.desktop $TERMUX_PREFIX/share/applications/0ad.desktop
	install -Dm644 $TERMUX_PKG_SRCDIR/build/resources/0ad.png $TERMUX_PREFIX/share/icons/hicolor/128x128/apps/0ad.png
	install -Dm644 $TERMUX_PKG_SRCDIR/build/resources/0ad.appdata.xml $TERMUX_PREFIX/share/metainfo/0ad.appdata.xml
	install -Dm644 $TERMUX_PKG_SRCDIR/build/resources/pyrogenesis.xml $TERMUX_PREFIX/share/mime/packages/pyrogenesis.xml

	# Install game data (contents of binaries/data into share/0ad)
	rm -rf $TERMUX_PREFIX/share/0ad
	cp -r $TERMUX_PKG_SRCDIR/binaries/data $TERMUX_PREFIX/share/0ad

	install -Dm755 $TERMUX_PKG_SRCDIR/build/resources/0ad.sh $TERMUX_PREFIX/bin/0ad
}

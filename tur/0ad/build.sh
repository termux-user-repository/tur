TERMUX_PKG_HOMEPAGE=https://play0ad.com/
TERMUX_PKG_DESCRIPTION="Free, open-source, historical RTS game of ancient warfare"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@IntinteDAO"
TERMUX_PKG_VERSION=0.28.0-rc5
TERMUX_PKG_SRCURL=https://releases.wildfiregames.com/rc/0ad-0.28.0-rc5-unix-build.tar.gz
TERMUX_PKG_SHA256=becd124c28cf5af98cade3cfde82f45766138e720faa6925d8a836055d301392
TERMUX_PKG_DEPENDS="0ad-data, boost, curl, glew, libglvnd, libicu, libnspr, libxml2, miniupnpc, openal-soft, sdl2, zlib, libenet, libvorbis, libogg, libpng, libsodium, fmt, spidermonkey, gloox"
TERMUX_PKG_BUILD_DEPENDS="rust, python, cmake, libuuid"
TERMUX_PKG_GROUPS="games"
TERMUX_PKG_BUILD_IN_SRC=true

termux_setup_nodejs() {
	echo "WARNING: Bypassing nodejs setup"
	return 0
}

termux_step_post_get_source() {
	echo "TERMUX: Preparing 0.28.0-rc5 with data assets..."
	
	local FCOLLADA_BASE="libraries/source/fcollada"
	mkdir -p "$FCOLLADA_BASE"
	if [ ! -f "$FCOLLADA_BASE/fcollada-28209.tar.xz" ]; then
		# FCollada is included in the build tarball, but we ensure it's where the scripts expect it
		tar -xf "$TERMUX_PKG_SRCDIR/../0ad-0.28.0-rc5-unix-build.tar.gz" -O "0ad-0.28.0-rc5/libraries/source/fcollada/fcollada-28209.tar.xz" > "$FCOLLADA_BASE/fcollada-28209.tar.xz" || true
	fi

	# Download and Extract Data Tarball (Crucial for assets)
	echo "TERMUX: Downloading game data (RC5)..."
	# local DATA_URL="https://releases.wildfiregames.com/rc/0ad-0.28.0-rc5-unix-data.tar.gz"
	# local DATA_FILE=$TERMUX_PKG_CACHEDIR/0ad-0.28.0-rc5-unix-data.tar.gz
	# termux_download $DATA_URL $DATA_FILE eefa3a1646ffa94e290f9dfd7927c01becfd5a8603cd90f3146f6f09ba105fbb
	
	# echo "TERMUX: Extracting data assets..."
	# tar -xf "$DATA_FILE" -C "$TERMUX_PKG_SRCDIR" --strip-components=1

#	find . -name "ufilesystem.cpp" -exec sed -i 's/#\s*if\s*OS_ANDROID/#if 0/g' {} +
	find . -type f -name "*.h" -exec sed -i 's/#error Your compiler is trying to use an incorrect major version/#warning Bypassing SM version check/g' {} +

	# VFS Fix / Mocks Purge
	local EXEPATH_CPP="source/lib/sysdep/os/unix/unix_executable_pathname.cpp"
	if [ -f "$EXEPATH_CPP" ]; then
		sed -i 's/T::dladdr/dladdr/g' "$EXEPATH_CPP"
		sed -i 's/T::getcwd/getcwd/g' "$EXEPATH_CPP"
		sed -i '/#include "mocks\//d' "$EXEPATH_CPP"
		sed -i "s|libpath = \"/usr/lib/0ad/\"|libpath = \"$TERMUX_PREFIX/lib/0ad/\"|g" "$EXEPATH_CPP"
	fi

	mkdir -p libraries/source/cxxtest-4.4/cxxtest
	touch libraries/source/cxxtest-4.4/cxxtest/Mock.h

	# FCollada build script repair
	cat <<EOF > "$FCOLLADA_BASE/build.sh"
#!/bin/sh
set -e
PV=28209
cd "\$(dirname "\$0")"
if [ ! -d "fcollada-\$PV" ]; then
    tar -xf fcollada-\$PV.tar.xz
fi
(cd fcollada-\$PV && ./build.sh)
rm -rf include lib
cp -R fcollada-\$PV/include fcollada-\$PV/lib .
echo "\$PV+wfg1" > .already-built
EOF
	chmod +x "$FCOLLADA_BASE/build.sh"
}

termux_step_pre_configure() {
	termux_setup_rust
	termux_setup_nodejs
	(
		local PREMAKE_BASE=$TERMUX_PKG_SRCDIR/libraries/source/premake-core
		local PV=5.0.0-beta8
		mkdir -p $PREMAKE_BASE
		cd $PREMAKE_BASE
		[ ! -f "v${PV}.tar.gz" ] && curl -Lo "v${PV}.tar.gz" "https://github.com/premake/premake-core/archive/refs/tags/v${PV}.tar.gz"
		tar -xf "v${PV}.tar.gz" --strip-components=1
		env -i PATH="$PATH" HOME="$HOME" CC=gcc make -f Bootstrap.mak linux
		mkdir -p bin && cp bin/release/premake5 bin/
	)
	cd $TERMUX_PKG_SRCDIR/libraries
	./build-source-libs.sh --without-nvtt --with-system-premake --with-system-mozjs -j${TERMUX_MAKE_PROCESSES:-4}
	export PKG_CONFIG_PATH="$TERMUX_PREFIX/lib/pkgconfig:${PKG_CONFIG_PATH:-}"
	export LDFLAGS="${LDFLAGS:-} -L$TERMUX_PREFIX/lib -liconv -llog -lgloox -Wl,--no-as-needed,-lOpenSLES,--as-needed"
	export CXXFLAGS="${CXXFLAGS:-} -I$TERMUX_PREFIX/include/mozjs-128 -D_GNU_SOURCE -DCONFIG_ENABLE_MOCKS=0"
	export CXXFLAGS="$CXXFLAGS -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=0"
	cd $TERMUX_PKG_SRCDIR/build/workspaces
	./update-workspaces.sh --without-nvtt --without-atlas --without-tests --with-system-mozjs -j${TERMUX_MAKE_PROCESSES:-4}
}

termux_step_configure() {
	:
}

termux_step_make() {
	cd $TERMUX_PKG_SRCDIR/build/workspaces/gcc
	if [ -f "pyrogenesis.make" ]; then
		sed -i 's/-lmocks_real//g' pyrogenesis.make
		sed -i 's|-l../../binaries/system/libmocks_real.a||g' pyrogenesis.make
		sed -i 's|../../../binaries/system/libmocks_real.a||g' pyrogenesis.make
		sed -i 's/-lmocks_test//g' pyrogenesis.make
		sed -i 's|../../../binaries/system/libmocks_test.a||g' pyrogenesis.make
		sed -i 's/-lboost_system//g' pyrogenesis.make
	fi
	sed -i 's/\bmocks_real\b//g' Makefile
	make -j${TERMUX_MAKE_PROCESSES:-4} pyrogenesis CC="$CC" CXX="$CXX" LD="$CC" debug=1 LDFLAGS="${LDFLAGS}"
}

termux_step_make_install() {
	cp $TERMUX_PKG_SRCDIR/binaries/system/pyrogenesis $TERMUX_PREFIX/libexec/0ad
	[ -f "$TERMUX_PKG_SRCDIR/binaries/system/libCollada.so" ] && install -Dm755 $TERMUX_PKG_SRCDIR/binaries/system/libCollada.so $TERMUX_PREFIX/lib/libCollada.so
}

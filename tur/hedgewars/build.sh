TERMUX_PKG_HOMEPAGE="https://hedgewars.org/"
TERMUX_PKG_DESCRIPTION="A free turn based strategy, artillery, action and comedy game"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@IntinteDAO"
TERMUX_PKG_VERSION="1.0.3"
TERMUX_PKG_SRCURL="https://www.hedgewars.org/download/releases/hedgewars-src-${TERMUX_PKG_VERSION}.tar.bz2"
TERMUX_PKG_SHA256="c5c1877c0bae1354c75d2b9527b6f9a9f79e99932e5d08b1f6f7de1708066130"
TERMUX_PKG_AUTO_UPDATE=false
TERMUX_PKG_DEPENDS="hedgewars-data, libc++, libphysfs, lua51, opengl, qt5-qtbase, sdl2 | sdl2-compat, sdl2-image, sdl2-mixer, sdl2-net, sdl2-ttf"
TERMUX_PKG_BUILD_DEPENDS="qt5-qtbase-cross-tools, qt5-qttools-cross-tools"
TERMUX_PKG_GROUPS="games"
TERMUX_PKG_HOSTBUILD=true
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DCMAKE_POLICY_VERSION_MINIMUM=3.5
-DBUILD_ENGINE_C=ON
-DNOSERVER=ON
-DNOVIDEOREC=ON
-DLUA_INCLUDE_DIR=${TERMUX_PREFIX}/include/lua5.1
-DLUA_LIBRARY=${TERMUX_PREFIX}/lib/liblua5.1.so
-DPHYSFS_INCLUDE_DIR=${TERMUX_PREFIX}/include
-DPHYSFS_LIBRARY=${TERMUX_PREFIX}/lib/libphysfs.so
"

termux_step_host_build() {
	# Hedgewars engine is written in Pascal. For non-x86/cross targets, upstream
	# supports BUILD_ENGINE_C=ON which translates Pascal to C99 via pas2c (Haskell).
	# Install GHC and Parsec on the host builder and compile pas2c natively.
	env -i PATH="$PATH" DEBIAN_FRONTEND=noninteractive sudo apt-get update
	env -i PATH="$PATH" DEBIAN_FRONTEND=noninteractive sudo apt-get install -yq --no-install-recommends \
		ghc libghc-parsec3-dev

	mkdir -p "$TERMUX_PKG_HOSTBUILD_DIR/bin"
	ghc -O2 \
		-i"$TERMUX_PKG_SRCDIR/tools/pas2c" \
		-odir "$TERMUX_PKG_HOSTBUILD_DIR" \
		-hidir "$TERMUX_PKG_HOSTBUILD_DIR" \
		"$TERMUX_PKG_SRCDIR/tools/pas2c/Main.hs" \
		-o "$TERMUX_PKG_HOSTBUILD_DIR/bin/pas2c"
}

termux_step_pre_configure() {
	export PATH="$TERMUX_PKG_HOSTBUILD_DIR/bin:$PATH"
}

TERMUX_PKG_HOMEPAGE=https://github.com/stsp/dj64dev
TERMUX_PKG_DESCRIPTION="development suite that allows to cross-build 64-bit programs for DOS"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@stsp"
TERMUX_PKG_VERSION=("0.5" "1.11")
TERMUX_PKG_SRCURL=("https://github.com/stsp/dj64dev/archive/refs/tags/${TERMUX_PKG_VERSION[0]}.tar.gz"
                   "https://github.com/stsp/thunk_gen/archive/refs/tags/${TERMUX_PKG_VERSION[1]}.tar.gz")
TERMUX_PKG_SHA256=("d9a35a429d4adda44e2d1d76ef9c9c6c7a515d1e1cc9d3fd09db425008123ac0"
                   "579f8bc5a6d090495a30ac6ac090bf62ce5633c1fbfefb1f087367d02970456a")
TERMUX_PKG_BUILD_DEPENDS="ctags-cross, libelf, pkg-config, python"
TERMUX_PKG_PYTHON_COMMON_BUILD_DEPS="ply, meson-python"
TERMUX_PKG_DEPENDS="pkg-config, libelf"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--disable-ncurses
--disable-32bit
"

termux_step_post_get_source() {
	local _TERMUX_PKG_NAME="thunk_gen"
	local _INSTALL_PREFIX=${TERMUX_PREFIX}/opt/${_TERMUX_PKG_NAME}/cross
	PKG_CONFIG=$(command -v pkg-config)
	AR=;CC=;CFLAGS=;CPPFLAGS=;CXX=;CXXFLAGS=;LD=;LDFLAGS=;PKG_CONFIG=;STRIP=
	termux_setup_meson
	unset AR CC CFLAGS CPPFLAGS CXX CXXFLAGS LD LDFLAGS PKG_CONFIG STRIP PKG_CONFIG_PATH
	$TERMUX_MESON setup --prefix ${_INSTALL_PREFIX} \
		$TERMUX_PKG_HOSTBUILD_DIR \
		${_TERMUX_PKG_NAME}-${TERMUX_PKG_VERSION[1]}
	$TERMUX_MESON install -C $TERMUX_PKG_HOSTBUILD_DIR
}

termux_step_pre_configure() {
	local _PREFIX_FOR_CTAGS=${TERMUX_PREFIX}/opt/ctags/cross
	local _TERMUX_PKG_NAME="thunk_gen"
	local _PREFIX_FOR_THUNK_GEN=${TERMUX_PREFIX}/opt/${_TERMUX_PKG_NAME}/cross
	export PATH="$PATH:${_PREFIX_FOR_CTAGS}/bin"
	export PKG_CONFIG_PATH="${_PREFIX_FOR_THUNK_GEN}/share/pkgconfig"
	cd $TERMUX_PKG_SRCDIR
	autoreconf -v -i -I m4
}

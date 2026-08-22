TERMUX_PKG_HOMEPAGE=https://github.com/dosemu2/comcom64
TERMUX_PKG_DESCRIPTION="64bit command.com"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@stsp"
TERMUX_PKG_VERSION=("0.5" "1.11")
TERMUX_PKG_SRCURL=("https://github.com/dosemu2/comcom64/archive/refs/tags/${TERMUX_PKG_VERSION[0]}.tar.gz"
                   "https://github.com/stsp/thunk_gen/archive/refs/tags/${TERMUX_PKG_VERSION[1]}.tar.gz")
TERMUX_PKG_SHA256=("7dd7f5db57309fdd25e13dc47f23eeeb5b85260aae9d9618ba6f1ea47c6fb13a"
                   "579f8bc5a6d090495a30ac6ac090bf62ce5633c1fbfefb1f087367d02970456a")
TERMUX_PKG_BUILD_DEPENDS="dj64dev, djstub-cross, pkg-config, python"
TERMUX_PKG_PYTHON_COMMON_BUILD_DEPS="ply, meson-python"
TERMUX_PKG_DEPENDS="dj64dev"

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
	local _PREFIX_FOR_DJSTUB=${TERMUX_PREFIX}/opt/djstub/cross
	local _TERMUX_PKG_NAME="thunk_gen"
	local _PREFIX_FOR_THUNK_GEN=${TERMUX_PREFIX}/opt/${_TERMUX_PKG_NAME}/cross
	export PATH="$PATH:$_PREFIX_FOR_DJSTUB/bin"
	export PKG_CONFIG_PATH="${_PREFIX_FOR_THUNK_GEN}/share/pkgconfig"
}

termux_step_make() {
	make -j $TERMUX_PKG_MAKE_PROCESSES 64
}

termux_step_make_install() {
	make install_64 prefix=$PREFIX
}

TERMUX_PKG_HOMEPAGE=https://github.com/dosemu2/fdpp
TERMUX_PKG_DESCRIPTION="64-bit DOS core"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@stsp"
TERMUX_PKG_VERSION=("1.11" "1.11")
TERMUX_PKG_SRCURL=("https://github.com/dosemu2/fdpp/archive/refs/tags/${TERMUX_PKG_VERSION[0]}.tar.gz"
                   "https://github.com/stsp/thunk_gen/archive/refs/tags/${TERMUX_PKG_VERSION[1]}.tar.gz")
TERMUX_PKG_SHA256=("66a66103847ed33167c9d869c9272d6a96613489b381060e61f84e385e8a3db5"
                   "579f8bc5a6d090495a30ac6ac090bf62ce5633c1fbfefb1f087367d02970456a")
TERMUX_PKG_BUILD_DEPENDS="nasm, libelf, pkg-config, python"
TERMUX_PKG_PYTHON_COMMON_BUILD_DEPS="ply, meson-python"
TERMUX_PKG_DEPENDS="libelf"

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

termux_step_configure() {
	local _TERMUX_PKG_NAME="thunk_gen"
	local _PREFIX_FOR_THUNK_GEN=${TERMUX_PREFIX}/opt/${_TERMUX_PKG_NAME}/cross
	export PKG_CONFIG_PATH="${_PREFIX_FOR_THUNK_GEN}/share/pkgconfig"
	cd $TERMUX_PKG_BUILDDIR
	$TERMUX_PKG_SRCDIR/configure
}

termux_step_make() {
	make -j $TERMUX_PKG_MAKE_PROCESSES -C $TERMUX_PKG_BUILDDIR prefix=$PREFIX CC=$CC CXX=$CXX
}

termux_step_make_install() {
	make -C $TERMUX_PKG_BUILDDIR install prefix=$PREFIX
}

TERMUX_PKG_HOMEPAGE=https://github.com/stsp/thunk_gen
TERMUX_PKG_DESCRIPTION="thunk generator for C and assembler"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@stsp"
TERMUX_PKG_VERSION="1.11"
TERMUX_PKG_SRCURL="https://github.com/stsp/thunk_gen/archive/refs/tags/${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=579f8bc5a6d090495a30ac6ac090bf62ce5633c1fbfefb1f087367d02970456a
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_HOSTBUILD=true
TERMUX_PKG_PLATFORM_INDEPENDENT=true
TERMUX_PKG_DEPENDS="python, python-ply"
TERMUX_PKG_NO_SHEBANG_FIX_FILES="
opt/${TERMUX_PKG_NAME}/cross/share/thunk_gen/*
"

termux_step_host_build() {
	# thunk-gen-cross subpackage cannot be built on-device
	if [[ "$TERMUX_ON_DEVICE_BUILD" == "true" ]]; then
		return
	fi

	# like in main repository's glib package
	AR=;CC=;CFLAGS=;CPPFLAGS=;CXX=;CXXFLAGS=;LD=;LDFLAGS=;PKG_CONFIG=;STRIP=
	termux_setup_meson
	unset AR CC CFLAGS CPPFLAGS CXX CXXFLAGS LD LDFLAGS PKG_CONFIG STRIP

	local _INSTALL_PREFIX="$TERMUX_PREFIX/opt/$TERMUX_PKG_NAME/cross"

	$TERMUX_MESON setup --prefix "$_INSTALL_PREFIX" \
		"$TERMUX_PKG_HOSTBUILD_DIR" "$TERMUX_PKG_SRCDIR"
	$TERMUX_MESON compile --verbose -C "$TERMUX_PKG_HOSTBUILD_DIR"
	$TERMUX_MESON install -C "$TERMUX_PKG_HOSTBUILD_DIR"
}

termux_step_pre_configure() {
	# ensures rebuilding the package always rebuilds thunk-gen-cross
	rm -f "$TERMUX_HOSTBUILD_MARKER"
	# this command causes the use of Meson directly in termux-packages toolchain
	rm -f "$TERMUX_PKG_SRCDIR/configure"
}

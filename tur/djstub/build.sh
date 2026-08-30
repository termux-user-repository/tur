TERMUX_PKG_HOMEPAGE=https://github.com/stsp/djstub
TERMUX_PKG_DESCRIPTION="go32-compatible stub that supports COFF, PE and ELF payloads"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@stsp"
TERMUX_PKG_VERSION="0.9-2"
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=https://github.com/stsp/djstub/archive/refs/tags/${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=ab58c8658d3e5a5ca870642b9c01afd7488701e234419cc25faab24e64a85eb5
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_DEPENDS="python"
TERMUX_PKG_BUILD_DEPENDS="smallerc, smallerc-cross"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_HOSTBUILD=true
TERMUX_PKG_PLATFORM_INDEPENDENT=true
TERMUX_PKG_NO_SHEBANG_FIX_FILES="
opt/${TERMUX_PKG_NAME}/cross/bin/*
"

termux_step_host_build() {
	# djstub-cross subpackage cannot be built on-device
	if [[ "$TERMUX_ON_DEVICE_BUILD" == "true" ]]; then
		return
	fi

	local _PREFIX_FOR_BUILD="${TERMUX_PREFIX}/opt/djstub/cross"
	local _PREFIX_FOR_SMALLERC="${TERMUX_PREFIX}/opt/smallerc/cross"
	export PATH="$PATH:$_PREFIX_FOR_SMALLERC/bin"
	cd "$TERMUX_PKG_SRCDIR"
	make -j "$TERMUX_PKG_MAKE_PROCESSES" prefix="$_PREFIX_FOR_BUILD"
	make install prefix="$_PREFIX_FOR_BUILD"
}

termux_step_pre_configure() {
	# ensures rebuilding the package always rebuilds djstub-cross
	rm -f "$TERMUX_HOSTBUILD_MARKER"

	if [[ "$TERMUX_ON_DEVICE_BUILD" == "false" ]]; then
		local _PREFIX_FOR_SMALLERC="${TERMUX_PREFIX}/opt/smallerc/cross"
		export PATH="$PATH:$_PREFIX_FOR_SMALLERC/bin"
	fi
}

TERMUX_PKG_HOMEPAGE=https://github.com/dosemu2/comcom64
TERMUX_PKG_DESCRIPTION="64bit command.com"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@stsp"
TERMUX_PKG_VERSION="0.5"
TERMUX_PKG_SRCURL="https://github.com/dosemu2/comcom64/archive/refs/tags/${TERMUX_PKG_VERSION[0]}.tar.gz"
TERMUX_PKG_SHA256="7dd7f5db57309fdd25e13dc47f23eeeb5b85260aae9d9618ba6f1ea47c6fb13a"
TERMUX_PKG_SETUP_PYTHON=true
TERMUX_PKG_DEPENDS="dj64dev"
TERMUX_PKG_BUILD_DEPENDS="djstub, djstub-cross, python, thunk-gen, thunk-gen-cross"

termux_step_pre_configure() {
	if [[ "$TERMUX_ON_DEVICE_BUILD" == "false" ]]; then
		local _PREFIX_FOR_DJSTUB="${TERMUX_PREFIX}/opt/djstub/cross"
		local _PREFIX_FOR_THUNK_GEN="${TERMUX_PREFIX}/opt/thunk-gen/cross"
		export PATH="$PATH:$_PREFIX_FOR_DJSTUB/bin"
		export PKG_CONFIG_PATH="${_PREFIX_FOR_THUNK_GEN}/share/pkgconfig"
	fi
}

termux_step_make() {
	make -j "$TERMUX_PKG_MAKE_PROCESSES" 64
}

termux_step_make_install() {
	make install_64 prefix="$TERMUX_PREFIX"
}

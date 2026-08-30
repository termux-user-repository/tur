TERMUX_PKG_HOMEPAGE=https://github.com/dosemu2/fdpp
TERMUX_PKG_DESCRIPTION="64-bit DOS core"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@stsp"
TERMUX_PKG_VERSION="1.11"
TERMUX_PKG_SRCURL="https://github.com/dosemu2/fdpp/archive/refs/tags/${TERMUX_PKG_VERSION[0]}.tar.gz"
TERMUX_PKG_SHA256="66a66103847ed33167c9d869c9272d6a96613489b381060e61f84e385e8a3db5"
TERMUX_PKG_SETUP_PYTHON=true
TERMUX_PKG_DEPENDS="libelf"
TERMUX_PKG_BUILD_DEPENDS="nasm, thunk-gen, thunk-gen-cross"

termux_step_pre_configure() {
	if [[ "$TERMUX_ON_DEVICE_BUILD" == "false" ]]; then
		local _PREFIX_FOR_THUNK_GEN="${TERMUX_PREFIX}/opt/thunk-gen/cross"
		export PKG_CONFIG_PATH="${_PREFIX_FOR_THUNK_GEN}/share/pkgconfig"
	fi

	TERMUX_PKG_EXTRA_MAKE_ARGS="CROSS_LD=$LD"
}

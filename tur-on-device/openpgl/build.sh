TERMUX_PKG_HOMEPAGE=http://www.openpgl.org/
TERMUX_PKG_DESCRIPTION="Intel(R) Open Path Guiding Library"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="0.7.0"
TERMUX_PKG_SRCURL="https://github.com/RenderKit/openpgl/archive/refs/tags/v$TERMUX_PKG_VERSION.tar.gz"
TERMUX_PKG_SHA256=58be6ac86e3bcf8a787e9c1332d1527e6d18f4b1403b96bb02c909e20af2ca94
TERMUX_PKG_DEPENDS="libc++, libtbb"
# OpenPGL does not support 32-bit
TERMUX_PKG_EXCLUDED_ARCHES="arm, i686"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DCMAKE_POLICY_VERSION_MINIMUM=3.5
-DOPENPGL_BUILD_STATIC=OFF
-DTBB_ROOT=$TERMUX_PREFIX
"

termux_step_pre_configure() {
	if [[ "$TERMUX_ON_DEVICE_BUILD" == "false" ]]; then
		termux_error_exit "This package is extremely hard to cross-compile. If you know how, please help!"
	fi
}

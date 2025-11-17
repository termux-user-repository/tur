TERMUX_PKG_HOMEPAGE=https://www.embree.org/
TERMUX_PKG_DESCRIPTION="High-performance ray tracing library developed at Intel"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="4.4.0"
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL="https://github.com/RenderKit/embree/archive/refs/tags/v$TERMUX_PKG_VERSION.tar.gz"
TERMUX_PKG_SHA256=acb517b0ea0f4b442235d5331b69f96192c28da6aca5d5dde0cbe40799638d5c
TERMUX_PKG_DEPENDS="libc++, libtbb"
TERMUX_PKG_BUILD_DEPENDS="freeglut, libxmu"
# Embree does not support 32-bit Linux
TERMUX_PKG_EXCLUDED_ARCHES="arm, i686"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DCMAKE_INSTALL_LIBDIR=$TERMUX__PREFIX__LIB_SUBDIR
-DCMAKE_INSTALL_INCLUDEDIR=$TERMUX__PREFIX__INCLUDE_SUBDIR
-DEMBREE_TUTORIALS=OFF
-DEMBREE_MAX_ISA=AVX512SKX
-DEMBREE_BACKFACE_CULLING=OFF
"

termux_step_pre_configure() {
	if [[ "$TERMUX_ON_DEVICE_BUILD" == "false" ]]; then
		termux_error_exit "This package is extremely hard to cross-compile. If you know how, please help!"
	fi
}

termux_step_post_make_install() {
	mv "$TERMUX_PREFIX"/embree-vars.* "$TERMUX_PREFIX/bin/"
}

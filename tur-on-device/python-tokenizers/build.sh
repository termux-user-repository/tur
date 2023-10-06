TERMUX_PKG_HOMEPAGE=https://github.com/huggingface/tokenizers
TERMUX_PKG_DESCRIPTION="Fast State-of-the-Art Tokenizers optimized for Research and Production"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="0.14.1"
TERMUX_PKG_SRCURL=https://github.com/huggingface/tokenizers/archive/refs/tags/v$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=d5ecf418a2b6a1d02d026f629ee4c2d78afc50e060984f35290dda2dcf823c63
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_DEPENDS="libc++, python"
TERMUX_PKG_SETUP_PYTHON=true
TERMUX_PKG_BUILD_IN_SRC=true

TERMUX_PKG_RM_AFTER_INSTALL="
lib/python${TERMUX_PYTHON_VERSION}/__pycache__
lib/python${TERMUX_PYTHON_VERSION}/site-packages/pip
"

termux_step_pre_configure() {
	if [ "${TERMUX_ON_DEVICE_BUILD}" = false ]; then
		termux_error_exit "This package doesn't support cross-compiling."
	fi

	LDFLAGS+=" -Wl,--no-as-needed -lpython${TERMUX_PYTHON_VERSION}"
	TERMUX_PKG_SRCDIR+="/bindings/python"
	TERMUX_PKG_BUILDDIR+="/bindings/python"
	rm -rf $TERMUX_PKG_SRCDIR/Makefile
}

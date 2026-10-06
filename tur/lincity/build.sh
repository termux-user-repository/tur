TERMUX_PKG_HOMEPAGE=https://sourceforge.net/projects/lincity/
TERMUX_PKG_DESCRIPTION="A city/country simulation game for X11"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@IntinteDAO"
TERMUX_PKG_VERSION=1.13.1
TERMUX_PKG_SRCURL=https://downloads.sourceforge.net/project/lincity/Lincity%20Development%20Source/${TERMUX_PKG_VERSION}/lincity-${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=7b4cbd11ffd4cbed79a0aadb25f2b1c34e25a8201182fbb259ce2f450fe5015d
TERMUX_PKG_DEPENDS="libx11, libxext, libxt, libxpm, gettext"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_GROUPS="games"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="--with-x --without-svga"

termux_step_pre_configure() {
	autoreconf -fi
	CFLAGS+=" -Wno-implicit-function-declaration -fcommon"
}

termux_step_post_configure() {
	find . -name "libtool" -exec sed -i 's/func_fatal_configuration "unsupported hardcode properties"/lib_linked=yes/g' {} +
}

termux_step_post_make_install() {
	# Install menu desktop entry and icon
	install -Dm644 -t "${TERMUX_PREFIX}/share/applications" "${TERMUX_PKG_BUILDER_DIR}/lincity.desktop"
	install -Dm644 -t "${TERMUX_PREFIX}/share/pixmaps" "${TERMUX_PKG_BUILDER_DIR}/lincity.xpm"
}

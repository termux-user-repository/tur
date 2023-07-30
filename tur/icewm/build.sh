TERMUX_PKG_HOMEPAGE="https://ice-wm.org/"
TERMUX_PKG_DESCRIPTION="Wonderful Win95-OS/2-Motif-like window manager"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="fervi"
TERMUX_PKG_VERSION=3.4.1
TERMUX_PKG_SRCURL=https://github.com/ice-wm/icewm/releases/download/${TERMUX_PKG_VERSION}/icewm-${TERMUX_PKG_VERSION}.tar.lz
TERMUX_PKG_SHA256=99988e35d0ed3b87ed231e7e8a44bb2a67cb36453372b2e911596a914d4c273b
TERMUX_PKG_DEPENDS="imlib2, libandroid-wordexp, libandroid-glob, libxcomposite, libxdamage, libxpm"
TERMUX_PKG_FORCE_CMAKE=true
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DCONFIG_I18N=OFF
-DENABLE_NLS=OFF
"

termux_step_pre_configure() {
	LDFLAGS+=" -landroid-glob -landroid-wordexp"
}

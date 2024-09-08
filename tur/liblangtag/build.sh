TERMUX_PKG_HOMEPAGE=https://bitbucket.org/tagoh/liblangtag/wiki/Home
TERMUX_PKG_DESCRIPTION="interface library to access/deal with tags for identifying languages"
TERMUX_PKG_LICENSE="LGPL-2.1, MPL-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=0.6.7
TERMUX_PKG_SRCURL=https://bitbucket.org/tagoh/liblangtag/downloads/liblangtag-${TERMUX_PKG_VERSION}.tar.bz2
TERMUX_PKG_SHA256=5ed6bcd4ae3f3c05c912e62f216cd1a44123846147f729a49fb5668da51e030e
TERMUX_PKG_DEPENDS="libxml2"

termux_step_pre_configure() {
	export ac_cv_va_copy=C99
}

termux_step_post_configure() {
	# Avoid overlinking
	sed -i 's/ -shared / -Wl,--as-needed\0/g' ./libtool
}

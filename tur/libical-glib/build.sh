TERMUX_PKG_HOMEPAGE=https://libical.github.io/libical/libical-glib/
TERMUX_PKG_DESCRIPTION="GObject wrapper for libical library"
TERMUX_PKG_LICENSE="LGPL-2.1-only OR MPL-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="3.0.20"
TERMUX_PKG_SRCURL=https://github.com/libical/libical/releases/download/v$TERMUX_PKG_VERSION/libical-$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=e73de92f5a6ce84c1b00306446b290a2b08cdf0a80988eca0a2c9d5c3510b4c2
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_DEPENDS="libical, libxml2"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS=" -DSHARED_ONLY=true -DICAL_GLIB=true -DUSE_BUILTIN_TZDATA=true -DPERL_EXECUTABLE=/usr/bin/perl"

termux_step_post_get_source() {
	# Do not forget to bump revision of reverse dependencies and rebuild them
	# after SOVERSION is changed.
	local _SOVERSION=3

	local v=$(sed -En 's/^set\(LIBICAL_LIB_MAJOR_VERSION\s+"?([0-9]+).*/\1/p' \
			CMakeLists.txt)
	if [ "${v}" != "${_SOVERSION}" ]; then
		termux_error_exit "SOVERSION guard check failed."
	fi
}

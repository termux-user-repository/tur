TERMUX_PKG_HOMEPAGE=https://libical.github.io/libical/libical-glib/
TERMUX_PKG_DESCRIPTION="GObject wrapper for libical library"
TERMUX_PKG_LICENSE="LGPL-2.1-only"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="3.0.20"
TERMUX_PKG_SRCURL=https://github.com/libical/libical/releases/download/v$TERMUX_PKG_VERSION/libical-$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=e73de92f5a6ce84c1b00306446b290a2b08cdf0a80988eca0a2c9d5c3510b4c2
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_DEPENDS="glib, libical, libxml2"
TERMUX_PKG_BUILD_DEPENDS="icu-devtools, gtk-doc"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="-DICAL_GLIB=true -DUSE_BUILTIN_TZDATA=true"
TERMUX_CMAKE_BUILD="Unix Makefiles"

TERMUX_PKG_HOMEPAGE="https://libdatachannel.org/"
TERMUX_PKG_DESCRIPTION="C/C++ WebRTC network library featuring Data Channels, Media Transport, and WebSockets"
TERMUX_PKG_LICENSE="MPL-2.0"
TERMUX_PKG_MAINTAINER="@lumaparallax"
TERMUX_PKG_VERSION="0.24.2"
TERMUX_PKG_SRCURL="git+https://github.com/paullouisageneau/libdatachannel"
TERMUX_PKG_GIT_BRANCH="v${TERMUX_PKG_VERSION}"
TERMUX_PKG_AUTO_UPDATE=true

TERMUX_PKG_DEPENDS="openssl"

TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DUSE_GNUTLS=OFF
-DUSE_NICE=OFF
-DNO_EXAMPLES=ON
-DNO_TESTS=ON
"

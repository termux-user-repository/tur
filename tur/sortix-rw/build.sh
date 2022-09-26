TERMUX_PKG_HOMEPAGE="https://sortix.org/rw/"
TERMUX_PKG_DESCRIPTION="A lightweight dd(1) alternative that doesn't resemble IBM JCL"
TERMUX_PKG_LICENSE="ISC"
#TERMUX_PKG_LICENSE_FILE=""
TERMUX_PKG_MAINTAINER="@flosnvjx"
TERMUX_PKG_VERSION=1.0
## https://gitlab.com/sortix/rw-portable
TERMUX_PKG_SRCURL="https://sortix.org/rw/release/rw-portable-$TERMUX_PKG_VERSION.tar.gz"
## found checksum in homepage
TERMUX_PKG_SHA256=50009730e36991dfe579716f91f4f616f5ba05ffb7bf69c03d41bf305ed93b6d
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_CONFLICTS=rw
#TERMUX_PKG_AUTO_UPDATE=true
#TERMUX_PKG_UPDATE_METHOD=repology

termux_step_pre_configure() {
	CFLAGS+=" $CPPFLAGS $LDFLAGS"
}

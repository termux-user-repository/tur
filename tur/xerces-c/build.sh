TERMUX_PKG_HOMEPAGE=https://xerces.apache.org/xerces-c/
TERMUX_PKG_DESCRIPTION="A validating XML parser written in a portable subset of C++"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@IntinteDAO"
TERMUX_PKG_VERSION=3.3.0
TERMUX_PKG_SRCURL=https://archive.apache.org/dist/xerces/c/3/sources/xerces-c-${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=9555f1d06f82987fbb4658862705515740414fd34b4db6ad2ed76a2dc08d3bde
TERMUX_PKG_DEPENDS="iconv, libicu"

termux_step_pre_configure() {
	if [ "$TERMUX_ARCH" = "arm" ]; then
		LDFLAGS+=" $($CC -print-libgcc-file-name)"
	fi
}
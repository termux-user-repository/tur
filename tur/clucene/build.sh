TERMUX_PKG_HOMEPAGE="http://clucene.sourceforge.net/"
TERMUX_PKG_DESCRIPTION="C++ port of the high-performance text search engine Lucene"
TERMUX_PKG_LICENSE="Apache-2.0, LGPL-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=2.3.3.4
TERMUX_PKG_SRCURL=https://downloads.sourceforge.net/clucene/clucene-core-${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=ddfdc433dd8ad31b5c5819cc4404a8d2127472a3b720d3e744e8c51d79732eab
TERMUX_PKG_DEPENDS="boost, zlib"
TERMUX_PKG_BUILD_DEPENDS="boost-headers"

termux_step_pre_configure() {
	CXXFLAGS+=" -std=c++11"
}

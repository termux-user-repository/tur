TERMUX_PKG_HOMEPAGE=https://github.com/thkukuk/libnsl
TERMUX_PKG_DESCRIPTION="This library contains the public client interface for NIS(YP) and NIS+ in a IPv6 ready version"
TERMUX_PKG_LICENSE="LGPL-2.1"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="2.0.1"
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=https://github.com/thkukuk/libnsl/archive/v$TERMUX_PKG_VERSION/libnsl-v$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=59048b53be8d3904bf939313debf13956a881b0de79da40f7719a77bcd1e9c53
TERMUX_PKG_DEPENDS="libtirpc"
# TERMUX_PKG_BUILD_IN_SRC=true

termux_step_pre_configure() {
	autoreconf -fiv
}

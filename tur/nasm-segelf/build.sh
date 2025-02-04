TERMUX_PKG_HOMEPAGE=https://github.com/stsp/nasm-segelf
TERMUX_PKG_DESCRIPTION="nasm fork with segelf patches"
TERMUX_PKG_LICENSE="BSD 2-Clause"
TERMUX_PKG_MAINTAINER="@stsp"
TERMUX_PKG_VERSION="2.16.01-3"
TERMUX_PKG_SRCURL=https://github.com/stsp/nasm-segelf/archive/refs/tags/nasm-segelf-${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=87564b98746a5d291001130d7d444d221aecacc22016284131e97d0ac7febf6b
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_VERSION_SED_REGEXP="s/nasm-segelf-//g"
TERMUX_PKG_HOSTBUILD=true

termux_step_host_build() {
	local _PREFIX_FOR_BUILD=${TERMUX_PREFIX}/opt/$TERMUX_PKG_NAME/cross
	cd $TERMUX_PKG_HOSTBUILD_DIR
	$TERMUX_PKG_SRCDIR/configure prefix=$_PREFIX_FOR_BUILD
	# not supporting parallel build
	make
	make install
}

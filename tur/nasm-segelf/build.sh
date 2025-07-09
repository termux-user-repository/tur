TERMUX_PKG_HOMEPAGE=https://github.com/stsp/nasm-segelf
TERMUX_PKG_DESCRIPTION="nasm fork with segelf patches"
TERMUX_PKG_LICENSE="BSD 2-Clause"
TERMUX_PKG_MAINTAINER="@stsp"
TERMUX_PKG_VERSION="2.16.01-4"
TERMUX_PKG_SRCURL=https://github.com/stsp/nasm-segelf/archive/refs/tags/nasm-segelf-${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=1f4185bca8a12f3143239b51dab17241672b612e75d7d178736400db8c8b64ea
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

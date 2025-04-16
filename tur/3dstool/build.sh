TERMUX_PKG_HOMEPAGE=https://github.com/dnasdw/3dstool
TERMUX_PKG_DESCRIPTION="An all-in-one tool for extracting/creating 3ds roms"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="1.2.6"
TERMUX_PKG_SRCURL=https://github.com/dnasdw/3dstool/archive/refs/tags/v$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256="7f6118bfe7b8e1ba87aa547a8cb892c29c9cc45ad817ee822121fa2142044859"
TERMUX_PKG_DEPENDS="capstone, libc++, libcurl, libiconv, openssl"
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_post_get_source() {
	# Remove vendored source
	rm -rf dep
}

termux_step_post_make_install() {
	install -Dm755 bin/Release/3dstool $TERMUX_PREFIX/bin/3dstool
}

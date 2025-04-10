TERMUX_PKG_HOMEPAGE=https://github.com/dnasdw/3dstool
TERMUX_PKG_DESCRIPTION="An all-in-one tool for extracting/creating 3ds roms"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="1.2.6"
TERMUX_PKG_SRCURL=git+https://github.com/john-peterson/3dstool/
TERMUX_PKG_GIT_BRANCH=termux
TERMUX_PKG_EXCLUDED_ARCHES="arm" # Some dependencies aren't available for arm
TERMUX_PKG_DEPENDS=libiconv,openssl,libcurl,capstone

termux_step_post_make_install() {
	install -Dm755 ../src/bin/Release/3dstool $TERMUX_PREFIX/bin/3dstool
}

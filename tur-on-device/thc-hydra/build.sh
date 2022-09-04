TERMUX_PKG_HOMEPAGE=https://github.com/vanhauser-thc/thc-hydra
TERMUX_PKG_DESCRIPTION="hydra"
TERMUX_PKG_LICENSE="AGPL-V3"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="9.3"
# Wait for the next version to be converted to releases.
TERMUX_PKG_SRCURL=https://github.com/vanhauser-thc/thc-hydra.git
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_DEPENDS="libssh,libssh2,zlib,openssl,openssl-1.1,libidn,libgcrypt,pcre,pcre2"
TERMUX_PKG_BUILD_DEPENDS="gcc-11"

termux_step_make() {
	CC=gcc-11 make
}

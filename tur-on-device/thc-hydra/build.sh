TERMUX_PKG_HOMEPAGE=https://github.com/vanhauser-thc/thc-hydra
TERMUX_PKG_DESCRIPTION="hydra"
TERMUX_PKG_LICENSE="AGPL-V3"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="9.5"
TERMUX_PKG_SRCURL=git+https://github.com/vanhauser-thc/thc-hydra
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_DEPENDS="libidn, libgcrypt, libssh, libssh2, openssl, openssl-1.1, pcre, pcre2, zlib"
TERMUX_PKG_BUILD_DEPENDS="desktop-file-utils"
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	if [ "${TERMUX_ON_DEVICE_BUILD}" = false ]; then
		termux_error_exit "This package doesn't support cross-compiling."
	fi
}

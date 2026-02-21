TERMUX_PKG_HOMEPAGE=https://github.com/AdaCore/gprconfig_kb
TERMUX_PKG_DESCRIPTION="GPR configuration knowledge base"
TERMUX_PKG_LICENSE="custom"
TERMUX_PKG_LICENSE_FILE="COPYING3, COPYING.RUNTIME"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="25.0.0"
TERMUX_PKG_SRCURL=https://github.com/AdaCore/gprconfig_kb/archive/refs/tags/v$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=802e6d38a3b110897924a9c16e143cb86360f2dde94bb5b9144c7c391e37b121
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	if [ "${TERMUX_ON_DEVICE_BUILD}" = false ]; then
		termux_error_exit "This package doesn't support cross-compiling."
	fi
}

termux_step_configure() {
	:
}

termux_step_make() {
	:
}

termux_step_make_install() {
	mkdir -p "$TERMUX_PREFIX"/share/gprconfig
	rm -rf "$TERMUX_PREFIX"/share/gprconfig
	cp -r "$TERMUX_PKG_SRCDIR"/db "$TERMUX_PREFIX"/share/gprconfig
}

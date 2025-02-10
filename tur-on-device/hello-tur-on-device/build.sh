TERMUX_PKG_HOMEPAGE=https://github.com/termux-user-repository/tur-on-device
TERMUX_PKG_DESCRIPTION="Dummy test for TUR on Device"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=1:0.1
TERMUX_PKG_REVISION=1
TERMUX_PKG_SKIP_SRC_EXTRACT=true
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_pre_configure() {
	if [ "${TERMUX_ON_DEVICE_BUILD}" = false ]; then
		termux_error_exit "This package doesn't support cross-compiling."
	fi
}

termux_step_make() {
	$CC $CFLAGS $CPPFLAGS $TERMUX_PKG_BUILDER_DIR/main.c -o hello-tur-on-device
}

termux_step_make_install() {
	install -Dm700 hello-tur-on-device $TERMUX_PREFIX/bin/hello-tur-on-device
}

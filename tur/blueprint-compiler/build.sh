TERMUX_PKG_HOMEPAGE="https://gitlab.gnome.org/jwestman/blueprint-compiler/"
TERMUX_PKG_DESCRIPTION="A markup language for GTK user interface files"
TERMUX_PKG_LICENSE="GPL-3.0-or-later"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=0.16.0
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=https://gitlab.gnome.org/jwestman/blueprint-compiler/-/archive/v${TERMUX_PKG_VERSION}/blueprint-compiler-v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=01feb8263fe7a450b0a9fed0fd54cf88947aaf00f86cc7da345f8b39a0e7bd30
TERMUX_PKG_DEPENDS="python, pygobject"
TERMUX_PKG_ANTI_BUILD_DEPENDS="pygobject"
TERMUX_PKG_SETUP_PYTHON=true
TERMUX_PKG_AUTO_UPDATE=true

TERMUX_MESON_WHEEL_CROSSFILE="$TERMUX_PKG_TMPDIR/wheel-cross-file.txt"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--cross-file $TERMUX_MESON_WHEEL_CROSSFILE
"

termux_step_pre_configure() {
	if $TERMUX_ON_DEVICE_BUILD; then
		termux_error_exit "Package '$TERMUX_PKG_NAME' is not available for on-device builds."
	fi
}

termux_step_configure() {
	termux_setup_meson

	cp -f $TERMUX_MESON_CROSSFILE $TERMUX_MESON_WHEEL_CROSSFILE
	sed -i 's|^\(\[binaries\]\)$|\1\npython = '\'$(command -v python)\''|g' \
		$TERMUX_MESON_WHEEL_CROSSFILE

	termux_step_configure_meson
}

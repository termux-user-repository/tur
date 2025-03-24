TERMUX_PKG_HOMEPAGE="https://gitlab.gnome.org/jwestman/blueprint-compiler/"
TERMUX_PKG_DESCRIPTION="A markup language for GTK user interface files"
TERMUX_PKG_LICENSE="GPL-3.0-or-later"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=0.16.0
TERMUX_PKG_SRCURL=https://gitlab.gnome.org/jwestman/blueprint-compiler/-/archive/v${TERMUX_PKG_VERSION}/blueprint-compiler-v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=01feb8263fe7a450b0a9fed0fd54cf88947aaf00f86cc7da345f8b39a0e7bd30
TERMUX_PKG_DEPENDS="python"
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_configure(){
	termux_setup_meson
}

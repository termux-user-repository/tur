TERMUX_PKG_HOMEPAGE=https://plib.sourceforge.net
TERMUX_PKG_DESCRIPTION="Provides a Joystick interface, a simple GUI built on top of OpenGL, some standard geometry functions, a sound library and a simple scene graph API built on top of OpenGL."
TERMUX_PKG_LICENSE="BSD"
TERMUX_PKG_MAINTAINER="@IntinteDAO"
TERMUX_PKG_VERSION=1.8.5
TERMUX_PKG_SRCURL=http://plib.sourceforge.net/dist/plib-${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=485b22bf6fdc0da067e34ead5e26f002b76326f6371e2ae006415dea6a380a32
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
ac_cv_lib_MesaGL_glNewList=yes
"

termux_step_pre_configure() {
	export LDFLAGS+=" -Wl,--no-as-needed,-lOpenSLES,--as-needed"
	./autogen.sh
	touch ltmain.sh
}

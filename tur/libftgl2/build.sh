TERMUX_PKG_HOMEPAGE=https://github.com/frankheckenbach/ftgl
TERMUX_PKG_DESCRIPTION="library to render text in OpenGL using FreeType"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@fervi"
TERMUX_PKG_VERSION="2.4.0"
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL="https://github.com/frankheckenbach/ftgl/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=aa97da1c3442a8fd3941037655df18016d70b5266381c81d81e8b5335f196ea8
TERMUX_PKG_DEPENDS="freetype, glu, opengl"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DCMAKE_SYSTEM_NAME=Linux
"

termux_step_post_massage() {
	# Do not forget to bump revision of reverse dependencies and rebuild them
	# after SOVERSION is changed.
	local _SOVERSION_GUARD_FILES="
lib/libftgl.so.2
"
	local f
	for f in ${_SOVERSION_GUARD_FILES}; do
		if [ ! -e "${f}" ]; then
			termux_error_exit "SOVERSION guard check failed."
		fi
	done
}

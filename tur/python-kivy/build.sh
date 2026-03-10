TERMUX_PKG_HOMEPAGE=https://kivy.org/
TERMUX_PKG_DESCRIPTION="Open source UI framework written in Python"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="2.3.1"
TERMUX_PKG_SRCURL="https://github.com/kivy/kivy/archive/refs/tags/$TERMUX_PKG_VERSION.tar.gz"
TERMUX_PKG_SHA256=83eee956b84ab7bf9e9d5b38544acc40a0e55f05cea7112fd01cda172c98244a
TERMUX_PKG_DEPENDS="mtdev, opengl, python, python-pillow, python-pip, sdl2, sdl2-image, sdl2-mixer, sdl2-ttf"
TERMUX_PKG_BUILD_DEPENDS="xorgproto"
TERMUX_PKG_PYTHON_COMMON_BUILD_DEPS="'Cython==3.0.11', wheel, packaging"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_RM_AFTER_INSTALL="
bin/
"

termux_step_pre_configure() {
	# error: incompatible function pointer types assigning to 'void (*)(GLuint, GLsizei, const GLchar **, const GLint *)' (aka 'void (*)(unsigned int, int, const char **, const int *)') from 'void (GLuint, GLsizei, const GLchar *const *, const GLint *)' (aka 'void (unsigned int, int, const char *const *, const int *)')
	CFLAGS+=" -Wno-incompatible-function-pointer-types"

	LDFLAGS+=" -lpython${TERMUX_PYTHON_VERSION}"
	export KIVY_SDL2_PATH="$TERMUX_PREFIX/include/SDL2"
}

termux_step_make_install() {
	export PYTHONPATH="$TERMUX_PREFIX/lib/python${TERMUX_PYTHON_VERSION}/site-packages"
	pip install --no-deps . --prefix "$TERMUX_PREFIX"
}

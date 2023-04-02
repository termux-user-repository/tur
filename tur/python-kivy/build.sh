TERMUX_PKG_HOMEPAGE=https://kivy.org/
TERMUX_PKG_DESCRIPTION="Open source UI framework written in Python"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
KIVY_VERSION_STATE=dev0
TERMUX_PKG_VERSION=2.2.0.${KIVY_VERSION_STATE}
TERMUX_PKG_SRCURL=git+https://github.com/kivy/kivy
TERMUX_PKG_GIT_BRANCH="master"
TERMUX_PKG_DEPENDS="mesa, mtdev, python, sdl2, sdl2-image, sdl2-mixer, sdl2-ttf, python-pillow"
TERMUX_PKG_BUILD_DEPENDS="xorgproto"
TERMUX_PKG_PYTHON_COMMON_DEPS="Cython, wheel"
TERMUX_PKG_PYTHON_BUILD_DEPS="${TERMUX_PKG_PYTHON_COMMON_DEPS}, packaging"
_PKG_PYTHON_DEPENDS="'Kivy-Garden>=0.1.4' docutils pygments"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_RM_AFTER_INSTALL="
bin/
"

termux_step_pre_configure() {
	LDFLAGS+=" -lpython${TERMUX_PYTHON_VERSION}"
	export KIVY_SDL2_PATH=$TERMUX_PREFIX/include/SDL2
}

termux_step_make_install() {
	export PYTHONPATH=$TERMUX_PREFIX/lib/python${TERMUX_PYTHON_VERSION}/site-packages
	pip install --no-deps . --prefix $TERMUX_PREFIX
}

termux_step_create_debscripts() {
	cat <<- EOF > ./postinst
	#!$TERMUX_PREFIX/bin/sh
	echo "Installing dependencies through pip..."
	pip3 install ${_PKG_PYTHON_DEPENDS}
	EOF
}

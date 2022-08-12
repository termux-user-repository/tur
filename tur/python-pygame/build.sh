TERMUX_PKG_HOMEPAGE=https://pygame.org/
TERMUX_PKG_DESCRIPTION="pygame is a python game library"
TERMUX_PKG_LICENSE="LGPL-3.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=2.1.3.dev4
TERMUX_PKG_SRCURL=https://github.com/pygame/pygame/archive/refs/tags/${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=bbe14ca0efc6f711e36cbf3cffc3801e0e72ba11d3beb7b2a2859805dd1d5fbe
TERMUX_PKG_DEPENDS="freetype, portmidi, python, sdl2, sdl2-image, sdl2-mixer, sdl2-ttf"
TERMUX_PKG_BUILD_DEPENDS="xorgproto ,sdl2 ,sdl2-image, sdl2-mixer, sdl2-ttf"

_PYTHON_VERSION=$(. $TERMUX_SCRIPTDIR/packages/python/build.sh; echo $_MAJOR_VERSION)

TERMUX_PKG_RM_AFTER_INSTALL="
bin/
lib/python${_PYTHON_VERSION}/site-packages/__pycache__
lib/python${_PYTHON_VERSION}/site-packages/easy-install.pth
lib/python${_PYTHON_VERSION}/site-packages/site.py
"

termux_step_pre_configure() {
        termux_setup_python_crossenv
        pushd $TERMUX_PYTHON_CROSSENV_SRCDIR
        _CROSSENV_PREFIX=$TERMUX_PKG_BUILDDIR/python-crossenv-prefix
        python${_PYTHON_VERSION} -m crossenv \
                $TERMUX_PREFIX/bin/python${_PYTHON_VERSION} \
                ${_CROSSENV_PREFIX}
        popd
        . ${_CROSSENV_PREFIX}/bin/activate

        pushd ${_CROSSENV_PREFIX}/build/lib/python${_PYTHON_VERSION}/site-packages
        patch --silent -p1 < $TERMUX_PKG_BUILDER_DIR/setuptools-44.1.1-no-bdist_wininst.diff || :
        popd

        build-pip install cython

        LDFLAGS+=" -lpython${_PYTHON_VERSION}"

        python setup.py install --force
}

termux_step_make_install() {
        export PYTHONPATH=$TERMUX_PREFIX/lib/python${_PYTHON_VERSION}/site-packages
        export PATH=$TERMUX_PREFIX/bin
        ls $TERMUX_PREFIX/bin | grep sdl2
        python setup.py install --force --prefix $TERMUX_PREFIX
}

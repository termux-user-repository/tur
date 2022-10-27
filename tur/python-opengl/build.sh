TERMUX_PKG_HOMEPAGE=http://pyopengl.sourceforge.net
TERMUX_PKG_DESCRIPTION="A cross-platform open source Python binding to the standard OpenGL API providing 2D and 3D graphic drawing"
TERMUX_PKG_LICENSE="BSD"
TERMUX_PKG_MAINTAINER="@fervi"
TERMUX_PKG_VERSION=3.1.6
TERMUX_PKG_SRCURL=https://files.pythonhosted.org/packages/5b/01/f8fd986bc7f456f1a925ee0239f0391838ade92cdb6e5b674ffb8b86cfd6/PyOpenGL-${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=8ea6c8773927eda7405bffc6f5bb93be81569a7b05c8cac50cd94e969dce5e27
TERMUX_PKG_DEPENDS="python, mesa"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_PLATFORM_INDEPENDENT=true

_PYTHON_VERSION=$(. $TERMUX_SCRIPTDIR/packages/python/build.sh; echo $_MAJOR_VERSION)

termux_step_pre_configure() {
    export PATH="$PATH:/data/data/com.termux/files/usr/bin"
        export PYTHONPATH=${TERMUX_PREFIX}/lib/python3.10/site-packages/
    termux_setup_python_crossenv
    pushd $TERMUX_PYTHON_CROSSENV_SRCDIR
    _CROSSENV_PREFIX=$TERMUX_PKG_BUILDDIR/python-crossenv-prefix
    python${_PYTHON_VERSION} -m crossenv \
	$TERMUX_PREFIX/bin/python${_PYTHON_VERSION} \
	${_CROSSENV_PREFIX}
    popd
    . ${_CROSSENV_PREFIX}/bin/activate
}

termux_step_make_install() {
	python setup.py install --force --prefix $TERMUX_PREFIX
}

termux_step_post_make_install() {
    pushd $TERMUX_PREFIX
    rm -rf lib/python${_PYTHON_VERSION}/site-packages/__pycache__
    rm -rf lib/python${_PYTHON_VERSION}/site-packages/easy-install.pth
    rm -rf lib/python${_PYTHON_VERSION}/site-packages/site.py
    popd
}

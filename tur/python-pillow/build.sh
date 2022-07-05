TERMUX_PKG_HOMEPAGE=https://github.com/python-pillow/Pillow
TERMUX_PKG_DESCRIPTION="The friendly PIL fork (Python Imaging Library)"
TERMUX_PKG_LICENSE="GNU"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=9.2.0
TERMUX_PKG_SRCURL=https://github.com/python-pillow/Pillow/archive/refs/tags/${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=95836f00972dbf724bf1270178683a0ac4ea23c6c3a980858fc9f2f9456e32ef
TERMUX_PKG_DEPENDS="libimagequant,freetype,littlecms,libtiff,libraqm,libxcb,zlib, build-essential, libjpeg-turbo, python"
TERMUX_PKG_BUILD_IN_SRC=true

_PYTHON_VERSION=3.10.5

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
	build-pip install wheel
	build-pip install tkinter
	LDFLAGS+=" -lpython${_PYTHON_VERSION}"
}

termux_step_make_install() {
	DEBVER=$TERMUX_PKG_VERSION \
		python setup.py install --force --prefix $TERMUX_PREFIX
}

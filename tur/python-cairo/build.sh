TERMUX_PKG_HOMEPAGE=https://cairographics.org/pycairo
TERMUX_PKG_DESCRIPTION="This package contains modules that allow you to use the Cairo vector graphics library in Python3 programs."
TERMUX_PKG_LICENSE="LGPL-2.1"
TERMUX_PKG_MAINTAINER="@fervi"
TERMUX_PKG_VERSION=1.21.0
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=https://github.com/pygobject/pycairo/releases/download/v${TERMUX_PKG_VERSION}/pycairo-${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=251907f18a552df938aa3386657ff4b5a4937dde70e11aa042bc297957f4b74b
TERMUX_PKG_DEPENDS="python, libcairo"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_configure() {
	_PYTHON_VERSION=$(. $TERMUX_SCRIPTDIR/packages/python/build.sh; echo $_MAJOR_VERSION)
	termux_setup_python_crossenv
	pushd $TERMUX_PYTHON_CROSSENV_SRCDIR
	_CROSSENV_PREFIX=$TERMUX_PKG_BUILDDIR/python-crossenv-prefix
	python${_PYTHON_VERSION} -m crossenv \
		$TERMUX_PREFIX/bin/python${_PYTHON_VERSION} \
		${_CROSSENV_PREFIX}
	popd
	. ${_CROSSENV_PREFIX}/bin/activate

	LDFLAGS+=" -lpython${_PYTHON_VERSION}"
	build-pip install wheel
}

termux_step_make_install() {
	export PYTHONPATH=$TERMUX_PREFIX/lib/python${_PYTHON_VERSION}/site-packages
	pip install --no-deps . --prefix $TERMUX_PREFIX
}

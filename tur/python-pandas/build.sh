# From: https://github.com/termux/termux-packages/blob/c4db683e0c337c1c9246c1c4b43252554e28b72d/disabled-packages/python-pandas/build.sh
TERMUX_PKG_HOMEPAGE=https://pandas.pydata.org/
TERMUX_PKG_DESCRIPTION="Powerful Python data analysis toolkit"
TERMUX_PKG_LICENSE="BSD 3-Clause"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="2.2.3"
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=git+https://github.com/pandas-dev/pandas
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_DEPENDS="libc++, python, python-numpy, python-pip"
_NUMPY_VERSION=$(. $TERMUX_SCRIPTDIR/packages/python-numpy/build.sh; echo $TERMUX_PKG_VERSION)
TERMUX_PKG_PYTHON_COMMON_DEPS="'Cython==3.0.5', 'numpy==$_NUMPY_VERSION', wheel, versioneer"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_UPDATE_TAG_TYPE="latest-release-tag"

termux_step_pre_configure() {
	CFLAGS="-I$TERMUX_PYTHON_HOME/site-packages/numpy/_core/include $CFLAGS"
	CPPFLAGS="-I$TERMUX_PYTHON_HOME/site-packages/numpy/_core/include $CPPFLAGS"
	CXXFLAGS="-I$TERMUX_PYTHON_HOME/site-packages/numpy/_core/include $CXXFLAGS"
	LDFLAGS+=" -lm"
}

termux_step_configure() {
	:
}

termux_step_make() {
	python setup.py bdist_wheel -vvv
}

termux_step_make_install() {
	pip install ./dist/*.whl --no-deps --prefix=$PREFIX -vvv
}

termux_step_create_debscripts() {
	cat <<- EOF > ./postinst
	#!$TERMUX_PREFIX/bin/sh
	echo "Installing dependencies through pip..."
	pip3 install pandas
	EOF
}

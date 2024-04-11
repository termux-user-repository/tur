# From: https://github.com/termux/termux-packages/blob/c4db683e0c337c1c9246c1c4b43252554e28b72d/disabled-packages/python-pandas/build.sh
TERMUX_PKG_HOMEPAGE=https://pandas.pydata.org/
TERMUX_PKG_DESCRIPTION="Powerful Python data analysis toolkit"
TERMUX_PKG_LICENSE="BSD 3-Clause"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="2.2.2"
TERMUX_PKG_SRCURL=git+https://github.com/pandas-dev/pandas
TERMUX_PKG_SHA256=d8abf9c2bf33cac75b28f32c174c29778414eb249e5e2ccb69b1079b97a8fc66
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_DEPENDS="libc++, python, python-numpy, python-pip"
TERMUX_PKG_PYTHON_COMMON_DEPS="'Cython==3.0.5', numpy, wheel, 'setuptools==63.2.0', versioneer"
TERMUX_PKG_PYTHON_TARGET_DEPS="'python-dateutil>=2.8.2', 'pytz>=2020.1', 'tzdata>=2022.1'"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_UPDATE_TAG_TYPE="latest-release-tag"

termux_step_pre_configure() {
	CFLAGS="-I$TERMUX_PYTHON_HOME/site-packages/numpy/core/include $CFLAGS"
	CPPFLAGS="-I$TERMUX_PYTHON_HOME/site-packages/numpy/core/include $CPPFLAGS"
	CXXFLAGS="-I$TERMUX_PYTHON_HOME/site-packages/numpy/core/include $CXXFLAGS"
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
	pip3 install ${TERMUX_PKG_PYTHON_TARGET_DEPS//, / }
	EOF
}

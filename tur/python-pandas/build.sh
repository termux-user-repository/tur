# From: https://github.com/termux/termux-packages/blob/c4db683e0c337c1c9246c1c4b43252554e28b72d/disabled-packages/python-pandas/build.sh
TERMUX_PKG_HOMEPAGE=https://pandas.pydata.org/
TERMUX_PKG_DESCRIPTION="Powerful Python data analysis toolkit"
TERMUX_PKG_LICENSE="BSD 3-Clause"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=2.0.1
TERMUX_PKG_SRCURL=git+https://github.com/pandas-dev/pandas.git
TERMUX_PKG_SHA256=d8abf9c2bf33cac75b28f32c174c29778414eb249e5e2ccb69b1079b97a8fc66
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_DEPENDS="libc++, python, python-numpy, python-pip"
TERMUX_PKG_SETUP_PYTHON=true
TERMUX_PKG_PYTHON_TARGET_DEPS_="'python-dateutil>=2.8.2', 'pytz>=2020.1', 'tzdata>=2022.1'"
TERMUX_PKG_BUILD_IN_SRC=true

TERMUX_PKG_RM_AFTER_INSTALL="
lib/python${TERMUX_PYTHON_VERSION}/__pycache__
lib/python${TERMUX_PYTHON_VERSION}/site-packages/pip
"

termux_step_pre_configure() {
	CFLAGS+=" -Wno-error=implicit-function-declaration -Wno-error=implicit-int -Wno-error=int-conversion -Wno-error=incompatible-function-pointer-types"
	CPPFLAGS+=" -Wno-error=implicit-function-declaration -Wno-error=implicit-int -Wno-error=int-conversion -Wno-error=incompatible-function-pointer-types"
	CXXFLAGS+=" -Wno-error=implicit-function-declaration -Wno-error=implicit-int -Wno-error=int-conversion -Wno-error=incompatible-function-pointer-types"
	LDFLAGS+=" -lm"
}

termux_step_make_install() {
	MATHLIB="m" pip install --no-deps . --prefix $TERMUX_PREFIX
}

termux_step_create_debscripts() {
	cat <<- EOF > ./postinst
	#!$TERMUX_PREFIX/bin/sh
	echo "Installing dependencies through pip..."
	pip3 install ${TERMUX_PKG_PYTHON_TARGET_DEPS_//, / }
	EOF
}

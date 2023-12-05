TERMUX_PKG_HOMEPAGE=https://github.com/scikit-image/scikit-image
TERMUX_PKG_DESCRIPTION="Image processing in Python"
TERMUX_PKG_LICENSE="BSD 2-Clause, BSD 3-Clause, MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="0.22.0"
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=https://github.com/scikit-image/scikit-image/archive/refs/tags/v$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=2875c81ffb224f9f25a1274734b502fb993cc729a2c790009d38035e52e6a123
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_DEPENDS="libc++, python, python-numpy, python-pillow, python-pywavelets, python-scipy"
TERMUX_PKG_BUILD_DEPENDS="python-pip"
TERMUX_PKG_SETUP_PYTHON=true
TERMUX_PKG_PYTHON_TARGET_DEPS_="'networkx>=2.8', 'imageio>=2.27', 'tifffile>=2022.8.12', 'packaging>=21', 'lazy_loader>=0.3'"
TERMUX_PKG_BUILD_IN_SRC=true

TERMUX_PKG_RM_AFTER_INSTALL="
lib/python${TERMUX_PYTHON_VERSION}/__pycache__
lib/python${TERMUX_PYTHON_VERSION}/site-packages/pip
lib/python${TERMUX_PYTHON_VERSION}/site-packages/numpy
"

termux_step_pre_configure() {
	if [ "${TERMUX_ON_DEVICE_BUILD}" = false ]; then
		termux_error_exit "This package doesn't support cross-compiling."
	fi

	LDFLAGS+=" -Wl,--no-as-needed -lpython${TERMUX_PYTHON_VERSION}"
}

termux_step_configure() {
	:
}

termux_step_make_install() {
	pip install wheel meson-python pythran cython
	pip install --no-build-isolation --no-deps . --prefix $TERMUX_PREFIX -vvv
}

termux_step_create_debscripts() {
	cat <<- EOF > ./postinst
	#!$TERMUX_PREFIX/bin/sh
	echo "Installing dependencies through pip..."
	pip3 install ${TERMUX_PKG_PYTHON_TARGET_DEPS_//, / }
	EOF
}

TERMUX_PKG_HOMEPAGE=https://numpy.org/
TERMUX_PKG_DESCRIPTION="The fundamental package for scientific computing with Python"
TERMUX_PKG_LICENSE="BSD 3-Clause"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
# Don't forget to bump the REVISION of python-scipy.
TERMUX_PKG_VERSION=1.23.0
TERMUX_PKG_SRCURL=https://github.com/numpy/numpy.git
TERMUX_PKG_PROVIDES="python-numpy"
TERMUX_PKG_DEPENDS="libc++, python"
TERMUX_PKG_BUILD_IN_SRC=true

_PYTHON_VERSION=$(. $TERMUX_SCRIPTDIR/packages/python/build.sh; echo $_MAJOR_VERSION)

TERMUX_PKG_RM_AFTER_INSTALL="
bin/
"

if $TERMUX_ON_DEVICE_BUILD; then
	termux_error_exit "Package '$TERMUX_PKG_NAME' is not available for on-device builds."
fi

termux_step_configure() {
	termux_setup_python_crossenv
	pushd $TERMUX_PYTHON_CROSSENV_SRCDIR
	_CROSSENV_PREFIX=$TERMUX_PKG_BUILDDIR/python-crossenv-prefix
	python${_PYTHON_VERSION} -m crossenv \
		$TERMUX_PREFIX/bin/python${_PYTHON_VERSION} \
		${_CROSSENV_PREFIX}
	popd
	. ${_CROSSENV_PREFIX}/bin/activate

	LDFLAGS+=" -lpython${_PYTHON_VERSION}"
}

termux_step_make() {
	build-pip install pybind11 Cython pythran wheel
	DEVICE_STIE=$TERMUX_PREFIX/lib/python${_PYTHON_VERSION}/site-packages
	MATHLIB="m" python setup.py install --force
}

termux_step_make_install() {
	export PYTHONPATH="$DEVICE_STIE"
	MATHLIB="m" python setup.py install --force --prefix $TERMUX_PREFIX

	pushd $DEVICE_STIE
	_NUMPY_EGGDIR=
	for f in numpy-${TERMUX_PKG_VERSION}-py${_PYTHON_VERSION}-linux-*.egg; do
		if [ -d "$f" ]; then
			_NUMPY_EGGDIR="$f"
			break
		fi
	done
	test -n "${_NUMPY_EGGDIR}"
	popd
}

termux_step_post_make_install() {
	# Delete the easy-install related files, since we use postinst/prerm to handle it.
	pushd $TERMUX_PREFIX
	rm -rf lib/python${_PYTHON_VERSION}/site-packages/__pycache__
	rm -rf lib/python${_PYTHON_VERSION}/site-packages/easy-install.pth
	rm -rf lib/python${_PYTHON_VERSION}/site-packages/site.py
	popd
}

termux_step_create_debscripts() {
	cat <<- EOF > ./postinst
	#!$TERMUX_PREFIX/bin/sh
	echo "Installing numpy..."
	echo "./${_NUMPY_EGGDIR}" >> $TERMUX_PREFIX/lib/python${_PYTHON_VERSION}/site-packages/easy-install.pth
	EOF

	cat <<- EOF > ./prerm
	#!$TERMUX_PREFIX/bin/sh
	sed -i "/\.\/${_NUMPY_EGGDIR//./\\.}/d" $TERMUX_PREFIX/lib/python${_PYTHON_VERSION}/site-packages/easy-install.pth
	EOF
}

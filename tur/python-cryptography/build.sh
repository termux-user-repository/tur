TERMUX_PKG_HOMEPAGE=https://cryptography.io/
TERMUX_PKG_DESCRIPTION="cryptography is a package designed to expose cryptographic primitives and recipes to Python developers. "
TERMUX_PKG_LICENSE="custom"
TERMUX_PKG_LICENSE_FILE="\
LICENSE
LICENSE.APACHE
LICENSE.BSD
LICENSE.PSF"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=37.0.4
TERMUX_PKG_SRCURL=https://github.com/pyca/cryptography/archive/refs/tags/${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=26cb3b7e5cb14345502737c30188b807c1a58e64c535d961e683e86d3300c112
TERMUX_PKG_DEPENDS="libffi, openssl, python"
TERMUX_PKG_BUILD_IN_SRC=true

_PYTHON_VERSION=$(. $TERMUX_SCRIPTDIR/packages/python/build.sh; echo $_MAJOR_VERSION)
_PKG_PYTHON_DEPENDS="'cffi>=1.12'"

TERMUX_PKG_RM_AFTER_INSTALL="
bin/
"

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

	# Dummy a pthread for successfully build.
	_DUMMY_PTHREAD=$TERMUX_PREFIX/lib/libpthread.so
	echo "INPUT(-lc)" > $_DUMMY_PTHREAD

	# Update the setuptools version of build python
	build-pip install --upgrade cffi 'setuptools>=60.10' setuptools_rust semantic_version
	cross-expose cffi
	# Cross python should have the same version of setuptools of build python
	SETUPTOOLS_VERSION=$(build-python -m pip show setuptools | grep "Version"  | sed -E "s/Version\: //g")
	python -m pip install setuptools==$SETUPTOOLS_VERSION setuptools_rust semantic_version

	# Setup rust cross toolchain
	termux_setup_rust
	export CARGO_BUILD_TARGET=$CARGO_TARGET_NAME
}

termux_step_make() {
	python setup.py install --force
}

termux_step_make_install() {
	export PYTHONPATH=$TERMUX_PREFIX/lib/python${_PYTHON_VERSION}/site-packages
	python setup.py install --force --prefix $TERMUX_PREFIX

	pushd $PYTHONPATH
	_CRYPTOGRAPHY_EGGDIR=
	for f in cryptography-${TERMUX_PKG_VERSION}-py${_PYTHON_VERSION}-linux-*.egg; do
		if [ -d "$f" ]; then
			_CRYPTOGRAPHY_EGGDIR="$f"
			break
		fi
	done
	test -n "${_CRYPTOGRAPHY_EGGDIR}"
	popd
}

termux_step_post_make_install() {
	# Remove dummy pthread.
	rm $_DUMMY_PTHREAD
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
	echo "Installing dependencies through pip. This may take a while..."
	pip3 install ${_PKG_PYTHON_DEPENDS}
	echo "./${_CRYPTOGRAPHY_EGGDIR}" >> $TERMUX_PREFIX/lib/python${_PYTHON_VERSION}/site-packages/easy-install.pth
	EOF

	cat <<- EOF > ./prerm
	#!$TERMUX_PREFIX/bin/sh
	sed -i "/\.\/${_CRYPTOGRAPHY_EGGDIR//./\\.}/d" $TERMUX_PREFIX/lib/python${_PYTHON_VERSION}/site-packages/easy-install.pth
	EOF
}

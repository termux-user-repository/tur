TERMUX_PKG_HOMEPAGE=https://github.com/python-pillow/Pillow
TERMUX_PKG_DESCRIPTION="The friendly PIL fork (Python Imaging Library)"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=9.2.0
TERMUX_PKG_SRCURL=https://github.com/python-pillow/Pillow/archive/refs/tags/${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=95836f00972dbf724bf1270178683a0ac4ea23c6c3a980858fc9f2f9456e32ef
TERMUX_PKG_DEPENDS="freetype, libimagequant, libjpeg-turbo, libraqm, libtiff, libxcb, littlecms, python, zlib"
TERMUX_PKG_BUILD_IN_SRC=true

TERMUX_PKG_RM_AFTER_INSTALL="
bin/
"

termux_step_pre_configure() {
	_PYTHON_VERSION=$(. $TERMUX_SCRIPTDIR/packages/python/build.sh; echo $_MAJOR_VERSION)

	if $TERMUX_ON_DEVICE_BUILD; then
		termux_error_exit "Package '$TERMUX_PKG_NAME' is not available for on-device builds."
	fi

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

	LDFLAGS+=" -lpython${_PYTHON_VERSION}"
}

termux_step_make() {
	INCLUDE=$TERMUX_PREFIX/include LIB=$TERMUX_PREFIX/lib \
		python setup.py install --force
}

termux_step_make_install() {
	export PYTHONPATH=$TERMUX_PREFIX/lib/python${_PYTHON_VERSION}/site-packages
	INCLUDE=$TERMUX_PREFIX/include LIB=$TERMUX_PREFIX/lib \
		python setup.py install --force --prefix $TERMUX_PREFIX

	pushd $PYTHONPATH
	_PILLOW_EGGDIR=
	for f in Pillow-${TERMUX_PKG_VERSION}-py${_PYTHON_VERSION}-linux-*.egg; do
		# .egg is a zip file or a directory. In Pillow, it's a zip file.
		if [ -f "$f" ]; then
			_PILLOW_EGGDIR="$f"
			break
		fi
	done
	test -n "${_PILLOW_EGGDIR}"
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
	echo "Installing Pillow..."
	echo "./${_PILLOW_EGGDIR}" >> $TERMUX_PREFIX/lib/python${_PYTHON_VERSION}/site-packages/easy-install.pth
	EOF

	cat <<- EOF > ./prerm
	#!$TERMUX_PREFIX/bin/sh
	sed -i "/\.\/${_PILLOW_EGGDIR//./\\.}/d" $TERMUX_PREFIX/lib/python${_PYTHON_VERSION}/site-packages/easy-install.pth
	EOF
}

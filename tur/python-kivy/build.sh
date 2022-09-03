TERMUX_PKG_HOMEPAGE=https://kivy.org/
TERMUX_PKG_DESCRIPTION="Open source UI framework written in Python"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=2.1.0
TERMUX_PKG_SRCURL=https://github.com/kivy/kivy/archive/refs/tags/${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=c4e611b823bd5440cfccbfdfe6501037bd82d21c45c26f7ec0f22155e0286bd4
TERMUX_PKG_DEPENDS="mesa, mtdev, python, sdl2, sdl2-image, sdl2-mixer, sdl2-ttf"
TERMUX_PKG_BUILD_DEPENDS="xorgproto"
_PKG_PYTHON_DEPENDS="'Kivy-Garden>=0.1.4' docutils pygments"
TERMUX_PKG_BUILD_IN_SRC=true

TERMUX_PKG_RM_AFTER_INSTALL="
bin/
"

termux_step_pre_configure() {
	_PYTHON_VERSION=$(. $TERMUX_SCRIPTDIR/packages/python/build.sh; echo $_MAJOR_VERSION)
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

	build-pip install cython

	LDFLAGS+=" -lpython${_PYTHON_VERSION}"
	export KIVY_SDL2_PATH=$TERMUX_PREFIX/include/SDL2

	python setup.py install --force
}

termux_step_make_install() {
	export PYTHONPATH=$TERMUX_PREFIX/lib/python${_PYTHON_VERSION}/site-packages
	python setup.py install --force --prefix $TERMUX_PREFIX

	pushd $PYTHONPATH
	_KIVY_EGGDIR=
	for f in Kivy-${TERMUX_PKG_VERSION}-py${_PYTHON_VERSION}-linux-*.egg; do
		if [ -d "$f" ]; then
			_KIVY_EGGDIR="$f"
			break
		fi
	done
	test -n "${_KIVY_EGGDIR}"
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
	echo "Installing dependencies through pip..."
	pip3 install ${_PKG_PYTHON_DEPENDS}
	echo "./${_KIVY_EGGDIR}" >> $TERMUX_PREFIX/lib/python${_PYTHON_VERSION}/site-packages/easy-install.pth
	EOF

	cat <<- EOF > ./prerm
	#!$TERMUX_PREFIX/bin/sh
	sed -i "/\.\/${_KIVY_EGGDIR//./\\.}/d" $TERMUX_PREFIX/lib/python${_PYTHON_VERSION}/site-packages/easy-install.pth
	EOF
}

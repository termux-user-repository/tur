TERMUX_PKG_HOMEPAGE=https://pygame.org/
TERMUX_PKG_DESCRIPTION="pygame is a python game library"
TERMUX_PKG_LICENSE="LGPL-3.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=2.1.3.dev4
TERMUX_PKG_SRCURL=https://github.com/pygame/pygame/archive/refs/tags/${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=bbe14ca0efc6f711e36cbf3cffc3801e0e72ba11d3beb7b2a2859805dd1d5fbe
TERMUX_PKG_DEPENDS="x11-repo, freetype, portmidi, python, sdl2, sdl2-image, sdl2-mixer, sdl2-ttf"
TERMUX_PKG_BUILD_DEPENDS="xorgproto"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_REVISION=3

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

	LDFLAGS+=" -lpython${_PYTHON_VERSION}"
}

termux_step_make_install() {
	export PYTHONPATH=$TERMUX_PREFIX/lib/python${_PYTHON_VERSION}/site-packages
	export PATH=$PATH:$TERMUX_PREFIX/bin

	python setup.py install --force --prefix $TERMUX_PREFIX

	pushd $PYTHONPATH
	_PYGAME_EGGDIR=
	for f in pygame-${TERMUX_PKG_VERSION}-py${_PYTHON_VERSION}-linux-*.egg; do
		if [ -f "$f" ]|| [ -d "$f" ]; then
			_PYGAME_EGGDIR="$f"
			break
		fi
	done
	test -n "${_PYGAME_EGGDIR}"
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
	echo "Installing pygame..."
	echo "./${_PYGAME_EGGDIR}" >> $TERMUX_PREFIX/lib/python${_PYTHON_VERSION}/site-packages/easy-install.pth
	EOF

	cat <<- EOF > ./prerm
	#!$TERMUX_PREFIX/bin/sh
	sed -i "/\.\/${_PYGAME_EGGDIR//./\\.}/d" $TERMUX_PREFIX/lib/python${_PYTHON_VERSION}/site-packages/easy-install.pth
	EOF
}

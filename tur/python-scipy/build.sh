TERMUX_PKG_HOMEPAGE=https://scipy.org/
TERMUX_PKG_DESCRIPTION="Fundamental algorithms for scientific computing in Python"
TERMUX_PKG_LICENSE="BSD 3-Clause"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="1.10.1"
TERMUX_PKG_SRCURL=git+https://github.com/scipy/scipy
TERMUX_PKG_DEPENDS="libc++, libopenblas, python, python-numpy"
TERMUX_PKG_BUILD_DEPENDS="python-numpy-static"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_TAG_TYPE="latest-release-tag"

# Tests will hang on arm and will failed with `Segmentation fault` on i686.
# See https://github.com/termux-user-repository/tur/pull/21#issue-1295483266.
# 
# The logs of this crash on i686 are as following. 
# linalg/tests/test_basic.py: Fatal Python error: Segmentation fault
# 
# Current thread 0xf7f4b580 (most recent call first):
#   File "/data/data/com.termux/files/usr/lib/python3.10/site-packages/scipy-1.8.0-py3.10-linux-i686.egg/scipy/linalg/_basic.py", line 1227 in lstsq
#   File "/data/data/com.termux/files/usr/lib/python3.10/site-packages/scipy-1.8.0-py3.10-linux-i686.egg/scipy/linalg/tests/test_basic.py", line 1047 in test_simple_overdet_complex
# XXX: Although it doesn't seem to work fine, I'd like to enable this package as it happens only on some functions.
# TERMUX_PKG_BLACKLISTED_ARCHES="arm, i686"

TERMUX_PKG_RM_AFTER_INSTALL="
bin/
"

source $TERMUX_SCRIPTDIR/common-files/setup_toolchain_gcc.sh

termux_step_configure() {
	if $TERMUX_ON_DEVICE_BUILD; then
		termux_error_exit "Package '$TERMUX_PKG_NAME' is not available for on-device builds."
	fi

	_NUMPY_VERSION=$(. $TERMUX_SCRIPTDIR/packages/python-numpy/build.sh; echo $TERMUX_PKG_VERSION)

	_setup_toolchain_ndk_gcc_11

	# XXX: `python` from main repo is built by TERMUX_STANDALONE_TOOLCHAIN and its _sysconfigdata.py
	# XXX: contains some FLAGS which is not supported by GNU Compiler Collections, such as '-Oz',  
	# XXX: `-static-openmp`. So we need to modify the _sysconfigdata.py.
	SYS_CONFIG_DATA_FILE="$(find $TERMUX_PREFIX/lib/python${TERMUX_PYTHON_VERSION} -name "_sysconfigdata*.py")"
	rm -rf  $TERMUX_PREFIX/lib/python${TERMUX_PYTHON_VERSION}/__pycache__
	cp $SYS_CONFIG_DATA_FILE $TERMUX_PKG_TMPDIR/$(basename $SYS_CONFIG_DATA_FILE)
	sed -E 's|-O[123sz]|-Os|g;s|-static-openmp||g' $TERMUX_PKG_TMPDIR/$(basename $SYS_CONFIG_DATA_FILE) |
		sed "s|$TERMUX_HOST_PLATFORM-clang++|$TERMUX_HOST_PLATFORM-g++|g" |
		sed "s|$TERMUX_HOST_PLATFORM-clang|$TERMUX_HOST_PLATFORM-gcc|g" > $SYS_CONFIG_DATA_FILE
	rm $TERMUX_PKG_TMPDIR/$(basename $SYS_CONFIG_DATA_FILE)

	termux_setup_python_pip

	LDFLAGS+=" -Wl,--no-as-needed,-lpython${TERMUX_PYTHON_VERSION}"
}

termux_step_make() {
	pip --no-cache-dir install wheel
	build-pip install numpy==$_NUMPY_VERSION pybind11 Cython pythran wheel

	DEVICE_SITE=$TERMUX_PREFIX/lib/python${TERMUX_PYTHON_VERSION}/site-packages

	# From https://gist.github.com/benfogle/85e9d35e507a8b2d8d9dc2175a703c22
	BUILD_SITE=${TERMUX_PYTHON_CROSSENV_PREFIX}/build/lib/python${TERMUX_PYTHON_VERSION}/site-packages
	INI=$(find $BUILD_SITE -name 'npymath.ini')
	LIBDIR=$(find $DEVICE_SITE -path '*/numpy/core/lib')
	INCDIR=$(find $DEVICE_SITE -path '*/numpy/core/include')
	cat <<-EOF > $INI 
	[meta]
	Name=npymath
	Description=Portable, core math library implementing C99 standard
	Version=0.1
	[variables]
	# Force it to find cross-build libs when we build scipy
	libdir=$LIBDIR
	includedir=$INCDIR
	[default]
	Libs=-L\${libdir} -lnpymath
	Cflags=-I\${includedir}
	Requires=mlib
	EOF

	cp $DEVICE_SITE/numpy/core/lib/libnpymath.a $TERMUX_PREFIX/lib
	cp $DEVICE_SITE/numpy/random/lib/libnpyrandom.a $TERMUX_PREFIX/lib

	cat <<- EOF > site.cfg
	[openblas]
	libraries = openblas
	library_dirs = $TERMUX_PREFIX/lib
	include_dirs = $TERMUX_PREFIX/include
	EOF

	# XXX: It's hard for pip to work, as scipy uses meson-python as backend.
	# XXX: More investigations are needed.
	F90=$FC F77=$FC python setup.py bdist_wheel -v
}

termux_step_make_install() {
	export PYTHONPATH="$DEVICE_SITE"
	F90=$FC F77=$FC pip install ./dist/*.whl --no-deps --prefix=$TERMUX_PREFIX
}

termux_step_post_make_install() {
	# Remove these dummy files.
	rm $TERMUX_PREFIX/lib/libnpymath.a
	rm $TERMUX_PREFIX/lib/libnpyrandom.a
	# Remove __pycache__ and _sysconfigdata.py
	rm $SYS_CONFIG_DATA_FILE
	rm -rf $TERMUX_PREFIX/lib/python${TERMUX_PYTHON_VERSION}/__pycache__
}

termux_step_create_debscripts() {
	cat <<- EOF > ./postinst
	#!$TERMUX_PREFIX/bin/sh
	INSTALLED_NUMPY_VERSION=\$(dpkg --list python-numpy | grep python-numpy | awk '{print \$3; exit;}')
	if [ "\${INSTALLED_NUMPY_VERSION%%-*}" != "$_NUMPY_VERSION" ]; then
		echo "WARNING: python-scipy is compiled with numpy $_NUMPY_VERSION, but numpy \${INSTALLED_NUMPY_VERSION%%-*} is installed. It seems that python-numpy has been upgraded. Please report it to https://github.com/termux-user-repository/tur if any bug happens."
	fi
	if [ "$TERMUX_ARCH" = "arm" ] || [ "$TERMUX_ARCH" = "i686" ]; then
		echo "WARNING: python-numpy doesn't work fine on 32-bit arches. See https://github.com/termux-user-repository/tur/pull/21#issue-1295483266 for detail."
	fi
	EOF
}

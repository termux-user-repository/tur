TERMUX_PKG_HOMEPAGE=https://scipy.org/
TERMUX_PKG_DESCRIPTION="Fundamental algorithms for scientific computing in Python"
TERMUX_PKG_LICENSE="BSD 3-Clause"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="1:1.16.2"
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=git+https://github.com/scipy/scipy
TERMUX_PKG_DEPENDS="libc++, libopenblas, python, python-numpy"
TERMUX_PKG_BUILD_DEPENDS="python-numpy-static"
TERMUX_PKG_PYTHON_COMMON_DEPS="wheel, 'Cython>=3.0.4', meson-python, build"
_NUMPY_VERSION=$(. $TERMUX_SCRIPTDIR/packages/python-numpy/build.sh; echo $TERMUX_PKG_VERSION)
TERMUX_PKG_PYTHON_BUILD_DEPS="pythran, 'pybind11>=2.10.4', 'numpy==$_NUMPY_VERSION'"
TERMUX_PKG_ON_DEVICE_BUILD_NOT_SUPPORTED=true
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
# TERMUX_PKG_EXCLUDED_ARCHES="arm, i686"

TERMUX_MESON_WHEEL_CROSSFILE="$TERMUX_PKG_TMPDIR/wheel-cross-file.txt"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-Dblas=openblas
-Dlapack=openblas
-Duse-pythran=true
--cross-file $TERMUX_MESON_WHEEL_CROSSFILE
"

TERMUX_PKG_RM_AFTER_INSTALL="
bin/
"

source $TERMUX_SCRIPTDIR/common-files/setup_toolchain_gcc.sh

termux_step_pre_configure() {
	# FIXME: Don't know why NDK's libc++ should link against clang's libunwind,
	# FIXME: otherwise pybind11's `register_local_exception_translator` won't
	# FIXME: work properly, causing crash on `scipy.io._mmio`.
	# FIXME: Besides, `__cxa_call_terminate` is introduced since gcc-14, but it
	# FIXME: doesn't exist on libcxx's libunwind since clang 19.1.0.
	if [ "$TERMUX_NDK_VERSION" != "28c" ]; then
		termux_error_exit "Please remove the workaround for __cxa_call_terminate."
	fi
	local _unwind_dir="$TERMUX_PKG_TMPDIR/_libunwind_libdir"
	local _NDK_ARCH=$TERMUX_ARCH
	test $_NDK_ARCH == 'i686' && _NDK_ARCH='i386'
	mkdir -p $_unwind_dir
	cp $NDK/toolchains/llvm/prebuilt/linux-x86_64/lib/clang/*/lib/linux/$_NDK_ARCH/libunwind.a \
		$_unwind_dir/libunwind.a
	$CXX $CPPFLAGS $CXXFLAGS -fPIC \
		-c $TERMUX_PKG_BUILDER_DIR/libunwind-extra.cpp \
		-o $_unwind_dir/libunwind-extra.o
	pushd $_unwind_dir
	$AR rcu libunwind-extra.a libunwind-extra.o
	popd # $_unwind_dir

	_setup_toolchain_ndk_gcc_15

	LDFLAGS+=" -Wl,--no-as-needed,-lpython${TERMUX_PYTHON_VERSION},--as-needed"
	LDFLAGS="-L$TERMUX_PKG_TMPDIR/_libunwind_libdir -l:libunwind.a -l:libunwind-extra.a ${LDFLAGS}"
}

termux_step_configure() {
	termux_setup_meson

	cp -f $TERMUX_MESON_CROSSFILE $TERMUX_MESON_WHEEL_CROSSFILE
	sed -i 's|^\(\[binaries\]\)$|\1\npython = '\'$(command -v python)\''|g' \
		$TERMUX_MESON_WHEEL_CROSSFILE
	sed -i 's|^\(\[properties\]\)$|\1\nnumpy-include-dir = '\'$PYTHON_SITE_PKG/numpy/_core/include\''|g' \
		$TERMUX_MESON_WHEEL_CROSSFILE

	(unset PYTHONPATH && termux_step_configure_meson)
}

termux_step_make() {
	pushd $TERMUX_PKG_SRCDIR
	PYTHONPATH= python -m build -w -n -x --config-setting builddir=$TERMUX_PKG_BUILDDIR .
	popd
}

termux_step_make_install() {
	local _pyv="${TERMUX_PYTHON_VERSION/./}"
	local _whl="scipy-${TERMUX_PKG_VERSION#*:}-cp$_pyv-cp$_pyv-linux_$TERMUX_ARCH.whl"
	pip install --no-deps --prefix=$TERMUX_PREFIX $TERMUX_PKG_SRCDIR/dist/$_whl
}

TERMUX_PKG_HOMEPAGE=https://github.com/scikit-image/scikit-image
TERMUX_PKG_DESCRIPTION="Image processing in Python"
TERMUX_PKG_LICENSE="BSD 2-Clause, BSD 3-Clause, MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="0.24.0"
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=https://github.com/scikit-image/scikit-image/archive/refs/tags/v$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=a2cf85577f8a9105ac46130277ad27e1627bfa3effecff7c1ef3ea851e5671ba
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_DEPENDS="libandroid-complex-math, libc++, python, python-pip, python-numpy, python-pillow, python-pywavelets, python-scipy"
TERMUX_PKG_PYTHON_COMMON_DEPS="wheel, 'Cython>=3.0.4', meson-python, build"
_NUMPY_VERSION=$(. $TERMUX_SCRIPTDIR/packages/python-numpy/build.sh; echo $TERMUX_PKG_VERSION)
TERMUX_PKG_PYTHON_BUILD_DEPS="pythran, 'numpy==$_NUMPY_VERSION'"
TERMUX_PKG_SETUP_PYTHON=true

TERMUX_MESON_WHEEL_CROSSFILE="$TERMUX_PKG_TMPDIR/wheel-cross-file.txt"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--cross-file $TERMUX_MESON_WHEEL_CROSSFILE
"

source $TERMUX_SCRIPTDIR/common-files/setup_toolchain_gcc.sh

termux_step_pre_configure() {
	if $TERMUX_ON_DEVICE_BUILD; then
		termux_error_exit "Package '$TERMUX_PKG_NAME' is not available for on-device builds."
	fi

	# FIXME: NDK r27b cannot compile pythran due to https://github.com/llvm/llvm-project/issues/76358
	_setup_toolchain_ndk_gcc_11

	# ERROR: ./lib/python3.12/site-packages/skimage/measure/_marching_cubes_lewiner_cy.cpython-312.so contains undefined symbols:
	#   139: 0000000000000000     0 NOTYPE  GLOBAL DEFAULT  UND cpow
	LDFLAGS+=" -landroid-complex-math"
	LDFLAGS+=" -Wl,--no-as-needed -lpython${TERMUX_PYTHON_VERSION}"

	# FIXME: Don't know why NDK's libc++ should link against clang's libunwind,
	# FIXME: otherwise pybind11's `register_local_exception_translator` won't
	# FIXME: work properly, causing crash on `scipy.io._mmio`.
	mkdir -p $TERMUX_PKG_TMPDIR/_libunwind_libdir
	local _NDK_ARCH=$TERMUX_ARCH
	test $_NDK_ARCH == 'i686' && _NDK_ARCH='i386'
	cp $NDK/toolchains/llvm/prebuilt/linux-x86_64/lib/clang/*/lib/linux/$_NDK_ARCH/libunwind.a \
		$TERMUX_PKG_TMPDIR/_libunwind_libdir/libunwind.a
	LDFLAGS="-L$TERMUX_PKG_TMPDIR/_libunwind_libdir -l:libunwind.a ${LDFLAGS}"
}

termux_step_configure() {
	termux_setup_meson

	cp -f $TERMUX_MESON_CROSSFILE $TERMUX_MESON_WHEEL_CROSSFILE
	sed -i 's|^\(\[binaries\]\)$|\1\npython = '\'$(command -v python)\''|g' \
		$TERMUX_MESON_WHEEL_CROSSFILE
	sed -i 's|^\(\[properties\]\)$|\1\nnumpy-include-dir = '\'$PYTHON_SITE_PKG/numpy/_core/include\''|g' \
		$TERMUX_MESON_WHEEL_CROSSFILE

	termux_step_configure_meson
}

termux_step_make() {
	unset PYTHONPATH
	pushd $TERMUX_PKG_SRCDIR
	python -m build -w -n -x --config-setting builddir=$TERMUX_PKG_BUILDDIR .
	popd
}

termux_step_make_install() {
	local _pyv="${TERMUX_PYTHON_VERSION/./}"
	local _whl="scikit_image-${TERMUX_PKG_VERSION#*:}-cp$_pyv-cp$_pyv-linux_$TERMUX_ARCH.whl"
	pip install --no-deps --prefix=$TERMUX_PREFIX $TERMUX_PKG_SRCDIR/dist/$_whl
}

termux_step_create_debscripts() {
	cat <<- EOF > ./postinst
	#!$TERMUX_PREFIX/bin/sh
	echo "Installing dependencies through pip..."
	pip3 install scikit-image==${TERMUX_PKG_VERSION#*:}
	EOF
}

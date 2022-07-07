TERMUX_PKG_HOMEPAGE=https://scipy.org/
TERMUX_PKG_DESCRIPTION="Fundamental algorithms for scientific computing in Python"
TERMUX_PKG_LICENSE="BSD 3-Clause"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=1.8.0
TERMUX_PKG_SRCURL=https://github.com/scipy/scipy.git
TERMUX_PKG_DEPENDS="libc++, openblas, python, python-numpy"
TERMUX_PKG_BUILD_DEPENDS="python-numpy-static"
TERMUX_PKG_BUILD_IN_SRC=true

_PYTHON_VERSION=$(. $TERMUX_SCRIPTDIR/packages/python/build.sh; echo $_MAJOR_VERSION)
_NUMPY_VERSION=$(. $TERMUX_SCRIPTDIR/tur/python-numpy/build.sh; echo $TERMUX_PKG_VERSION)
_PKG_PYTHON_DEPENDS="numpy==$_NUMPY_VERSION"

if $TERMUX_ON_DEVICE_BUILD; then
	termux_error_exit "Package '$TERMUX_PKG_NAME' is not available for on-device builds."
fi

TERMUX_PKG_RM_AFTER_INSTALL="
bin/
"

# XXX: This step will setup an old NDK toolchain (r17c) containing gcc and
# XXX: gfortran. If NDK toolchain with llvm contains fortran compiler, this
# XXX: step may be unnecessary.
_setup_fortran_toolchain_r17c() {
	mkdir -p $TERMUX_COMMON_CACHEDIR/android-gfortran/r17c
	local _NDK_ARCHIVE_FILE=$TERMUX_COMMON_CACHEDIR/android-gfortran/android-ndk-r17c-linux-x86_64.zip
	local _NDK_URL=https://dl.google.com/android/repository/android-ndk-r17c-linux-x86_64.zip
	local _NDK_SHA256=3f541adbd0330a9205ba12697f6d04ec90752c53d6b622101a2a8a856e816589
	local _NDK_GF_ARCH
	local _NDK_GF_SHA256
	if [ "$TERMUX_ARCH" == "aarch64" ]; then
		_NDK_GF_ARCH="arm64"
		_NDK_GF_SHA256=dcbed5edeabb77533fcef0e76a9da9e4b1e23089f3a6be31824ff411058df7fd
		_NDK_GF_TOOLCHAIN_NAME="aarch64-linux-android-4.9"
	elif [ "$TERMUX_ARCH" == "arm" ]; then
		_NDK_GF_ARCH="arm"
		_NDK_GF_SHA256=75a15fd03e139f6326be604728cbec9d9d3d295942cc13d91766e40bcdd9a9e8
		_NDK_GF_TOOLCHAIN_NAME="arm-linux-androideabi-4.9"
	elif [ "$TERMUX_ARCH" == "x86_64" ]; then
		_NDK_GF_ARCH="x86_64"
		_NDK_GF_SHA256=27f683840e0453bd63cee5c9d3a6e41d2b90b4e86f20a13e74f78a9699d73401
		_NDK_GF_TOOLCHAIN_NAME="x86_64-4.9"
	elif [ "$TERMUX_ARCH" == "i686" ]; then
		_NDK_GF_ARCH="x86"
		_NDK_GF_SHA256=35f1491a9067c1a593430ebda812346ed528921730f2473c8dd9e847401167a2
		_NDK_GF_TOOLCHAIN_NAME="x86-4.9"
	fi
	local _NDK_GF_FILE=$TERMUX_COMMON_CACHEDIR/android-gfortran/r17c/gcc-$_NDK_GF_ARCH-linux-x86_64.tar.bz2
	local _NDK_GF_URL=https://github.com/licy183/android-gfortran/releases/download/r17/gcc-$_NDK_GF_ARCH-linux-x86_64.tar.bz2
	local _NDK_TOOLCHAIN_TARGET=$TERMUX_PKG_TMPDIR/android-ndk-r17c/toolchains/$_NDK_GF_TOOLCHAIN_NAME/prebuilt/linux-x86_64
	termux_download $_NDK_URL $_NDK_ARCHIVE_FILE $_NDK_SHA256
	unzip -d $TERMUX_PKG_TMPDIR/ $_NDK_ARCHIVE_FILE > /dev/null 2>&1
	termux_download $_NDK_GF_URL $_NDK_GF_FILE $_NDK_GF_SHA256
	tar -jxf $_NDK_GF_FILE -C $TERMUX_PKG_TMPDIR/
	rm -rf $_NDK_TOOLCHAIN_TARGET
	mv $TERMUX_PKG_TMPDIR/$_NDK_GF_TOOLCHAIN_NAME $_NDK_TOOLCHAIN_TARGET
	export GFORTRAN_TOOLCHAIN=$TERMUX_PKG_TMPDIR/ndk-$TERMUX_ARCH-with-gfortran
	python $TERMUX_PKG_TMPDIR/android-ndk-r17c/build/tools/make_standalone_toolchain.py \
					--arch $_NDK_GF_ARCH --api $TERMUX_PKG_API_LEVEL --install-dir $GFORTRAN_TOOLCHAIN
}

termux_step_configure() {
	_setup_fortran_toolchain_r17c
	CFLAGS="${CFLAGS/-static-openmp/''}"
	CXXFLAGS="${CXXFLAGS/-static-openmp/''}"
	LDFLAGS="${LDFLAGS/-static-openmp/''}"

	CROSS_PREFIX=$TERMUX_ARCH-linux-android
	if [ "$TERMUX_ARCH" == "arm" ]; then
		CROSS_PREFIX=arm-linux-androideabi
	fi

	# XXX: Only using gfortran, is it compatible with llvm?
	export FC=$CROSS_PREFIX-gfortran
	# XXX: `python` from main repo is built by TERMUX_STANDALONE_TOOLCHAIN and its _sysconfigdata.py
	# XXX: contains some FLAGS which is not supported by clang/ld.lld from GFORTRAN_TOOLCHAIN,
	# XXX: such as `-static-openmp`. Replacing these FLAGS in `_sysconfigdata.py` is a solution,
	# XXX: but I think it is unnecessary. That is the reason why putting GFORTRAN_TOOLCHAIN
	# XXX: behind TERMUX_STANDALONE_TOOLCHAIN.
	export PATH="$PATH:$GFORTRAN_TOOLCHAIN/bin"

	# We set `python-scipy` as dependencies, but python-crossenv prefer to use a fake one.
	DEVICE_STIE=$TERMUX_PREFIX/lib/python${_PYTHON_VERSION}/site-packages
	pushd $DEVICE_STIE
	_NUMPY_EGGDIR=
	for f in numpy-${_NUMPY_VERSION}-py${_PYTHON_VERSION}-linux-*.egg; do
		if [ -d "$f" ]; then
			_NUMPY_EGGDIR="$f"
			break
		fi
	done
	test -n "${_NUMPY_EGGDIR}"
	popd
	mv $DEVICE_STIE/$_NUMPY_EGGDIR $TERMUX_PREFIX/tmp/$_NUMPY_EGGDIR

	termux_setup_python_crossenv
	pushd $TERMUX_PYTHON_CROSSENV_SRCDIR
	_CROSSENV_PREFIX=$TERMUX_PKG_BUILDDIR/python-crossenv-prefix
	python${_PYTHON_VERSION} -m crossenv \
		$TERMUX_PREFIX/bin/python${_PYTHON_VERSION} \
		${_CROSSENV_PREFIX}
	popd
	. ${_CROSSENV_PREFIX}/bin/activate

	LDFLAGS+=" -Wl,--no-as-needed,-lpython${_PYTHON_VERSION}"
}

termux_step_make() {
	MATHLIB="m" pip --no-cache-dir install $_PKG_PYTHON_DEPENDS wheel
	build-pip install $_PKG_PYTHON_DEPENDS pybind11 Cython pythran wheel

	# From https://gist.github.com/benfogle/85e9d35e507a8b2d8d9dc2175a703c22
	BUILD_SITE=${_CROSSENV_PREFIX}/build/lib/python${_PYTHON_VERSION}/site-packages
	CROSS_SITE=${_CROSSENV_PREFIX}/cross/lib/python${_PYTHON_VERSION}/site-packages
	INI=$(find $BUILD_SITE -name 'npymath.ini')
	LIBDIR=$(find $CROSS_SITE -path '*/numpy/core/lib')
	INCDIR=$(find $CROSS_SITE -path '*/numpy/core/include')
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
	_ADDTIONAL_FILES=()
	cp $CROSS_SITE/numpy/core/lib/libnpymath.a $TERMUX_PREFIX/lib
	cp $CROSS_SITE/numpy/random/lib/libnpyrandom.a $TERMUX_PREFIX/lib
	_ADDTIONAL_FILES+=("$TERMUX_PREFIX/lib/libnpymath.a")
	_ADDTIONAL_FILES+=("$TERMUX_PREFIX/lib/libnpyrandom.a")
	cat <<- EOF > site.cfg
	[openblas]
	libraries = openblas
	library_dirs = $TERMUX_PREFIX/lib
	include_dirs = $TERMUX_PREFIX/include
	EOF

	F90=$FC F77=$FC python setup.py install --force
}

termux_step_make_install() {
	export PYTHONPATH="$DEVICE_STIE"
	F90=$FC F77=$FC python setup.py install --force --prefix $TERMUX_PREFIX

	pushd $DEVICE_STIE
	_SCIPY_EGGDIR=
	for f in scipy-${TERMUX_PKG_VERSION}-py${_PYTHON_VERSION}-linux-*.egg; do
		if [ -d "$f" ]; then
			_SCIPY_EGGDIR="$f"
			break
		fi
	done
	test -n "${_SCIPY_EGGDIR}"
	popd
}

termux_step_post_make_install() {
	# Remove these dummy files.
	rm "${_ADDTIONAL_FILES[@]}"
	# Recovery numpy
	mv $TERMUX_PREFIX/tmp/$_NUMPY_EGGDIR $DEVICE_STIE/$_NUMPY_EGGDIR
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
	echo "./${_SCIPY_EGGDIR}" >> $TERMUX_PREFIX/lib/python${_PYTHON_VERSION}/site-packages/easy-install.pth
	EOF

	cat <<- EOF > ./prerm
	#!$TERMUX_PREFIX/bin/sh
	sed -i "/\.\/${_SCIPY_EGGDIR//./\\.}/d" $TERMUX_PREFIX/lib/python${_PYTHON_VERSION}/site-packages/easy-install.pth
	EOF
}

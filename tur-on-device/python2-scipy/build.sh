TERMUX_PKG_HOMEPAGE=https://scipy.org/
TERMUX_PKG_DESCRIPTION="Fundamental algorithms for scientific computing in Python"
TERMUX_PKG_LICENSE="BSD 3-Clause"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="1.2.3"
TERMUX_PKG_SRCURL=https://files.pythonhosted.org/packages/62/4f/7e95c5000c411164d5ca6f55ac54cda5d200a3b6719dafd215ee0bd61578/scipy-$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=ecbe6413ca90b8e19f8475bfa303ac001e81b04ec600d17fa7f816271f7cca57
TERMUX_PKG_DEPENDS="libc++, libopenblas, python2, python2-numpy"
TERMUX_PKG_BUILD_DEPENDS="binutils, which, gcc-11, python2-numpy-static"
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_pre_configure() {
	if [ "${TERMUX_ON_DEVICE_BUILD}" = false ]; then
		termux_error_exit "This package doesn't support cross-compiling."
	fi

	local CROSS_PREFIX=$TERMUX_ARCH-linux-android
	if [ "$TERMUX_ARCH" == "arm" ]; then
		CROSS_PREFIX=arm-linux-androideabi
	fi

	# Use a wrapper to ignore `-static-openmp`
	mkdir -p $TERMUX_PKG_TMPDIR/_fake_bin
	sed -e "s|@TERMUX_PREFIX@|${TERMUX_PREFIX}|g" \
		-e "s|@COMPILER@|$(command -v ${CROSS_PREFIX}-gfortran-11)|g" \
		"$TERMUX_PKG_BUILDER_DIR"/wrapper.in \
		> $TERMUX_PKG_TMPDIR/_fake_bin/gfortran
	chmod +x $TERMUX_PKG_TMPDIR/_fake_bin/gfortran
	export PATH="$TERMUX_PKG_TMPDIR/_fake_bin:$PATH"

	CPPFLAGS+=" -Wno-implicit-function-declaration -Wno-implicit-int -Wno-error=register -Wno-error=incompatible-function-pointer-types"
	CFLAGS+=" -Wno-implicit-function-declaration -Wno-implicit-int -Wno-error=register -Wno-error=incompatible-function-pointer-types"
	CXXFLAGS+=" -Wno-implicit-function-declaration -Wno-implicit-int -Wno-error=register -Wno-error=incompatible-function-pointer-types"
	LDFLAGS+=" -Wl,--no-as-needed -lpython2.7"

	# https://github.com/scipy/scipy/issues/11611
	export FFLAGS="-fallow-argument-mismatch"
}

termux_step_configure() {
	:
}

termux_step_make() {
	:
}

termux_step_make_install() {
	python2 -m pip install . --prefix=$TERMUX_PREFIX -vv
}

termux_step_post_massage() {
	cd $TERMUX_PKG_MASSAGEDIR/$TERMUX_PREFIX || exit 1
	bash

	local _rm_files="lib/python2.7/!(site-packages)"
	shopt -s extglob
	rm -rfv $_rm_files
	shopt -u extglob

	rm -rfv bin
}

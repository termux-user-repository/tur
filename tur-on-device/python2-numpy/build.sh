TERMUX_PKG_HOMEPAGE=https://github.com/scikit-image/scikit-image
TERMUX_PKG_DESCRIPTION="Image processing in Python"
TERMUX_PKG_LICENSE="BSD 2-Clause, BSD 3-Clause, MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="1.16.6"
TERMUX_PKG_SRCURL=https://files.pythonhosted.org/packages/b7/6f/24647f014eef9b67a24adfcbcd4f4928349b4a0f8393b3d7fe648d4d2de3/numpy-$TERMUX_PKG_VERSION.zip
TERMUX_PKG_SHA256=e5cf3fdf13401885e8eea8170624ec96225e2174eb0c611c6f26dd33b489e3ff
TERMUX_PKG_DEPENDS="libc++, libopenblas, python2"
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_pre_configure() {
	if [ "${TERMUX_ON_DEVICE_BUILD}" = false ]; then
		termux_error_exit "This package doesn't support cross-compiling."
	fi

	LDFLAGS+=" -Wl,--no-as-needed -lpython2.7"
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

	local _rm_files="lib/python2.7/!(site-packages)"
	shopt -s extglob
	rm -rfv $_rm_files
	shopt -u extglob

	rm -rfv bin
}

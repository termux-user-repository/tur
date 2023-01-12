TERMUX_PKG_HOMEPAGE=https://github.com/decathorpe/mitmproxy_wireguard
TERMUX_PKG_DESCRIPTION="WireGuard frontend for mitmproxy"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="0.1.20"
TERMUX_PKG_SRCURL=https://github.com/decathorpe/mitmproxy_wireguard/archive/refs/tags/$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=04370f40d24efe4dd68d787ff34eb0c1fad78221abbc35c840d3b3d2cbb3e06d
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_DEPENDS="libc++, openssl, python"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_UPDATE_TAG_TYPE="newest-tag"

termux_step_pre_configure() {
	_PYTHON_VERSION=$(. $TERMUX_SCRIPTDIR/packages/python/build.sh; echo $_MAJOR_VERSION)

	termux_setup_rust

	termux_setup_python_crossenv
	pushd $TERMUX_PYTHON_CROSSENV_SRCDIR
	_CROSSENV_PREFIX=$TERMUX_PKG_BUILDDIR/python-crossenv-prefix
	python${_PYTHON_VERSION} -m crossenv \
		$TERMUX_PREFIX/bin/python${_PYTHON_VERSION} \
		${_CROSSENV_PREFIX}
	popd
	. ${_CROSSENV_PREFIX}/bin/activate

	build-pip install maturin

	LDFLAGS+=" -Wl,--no-as-needed -lpython${_PYTHON_VERSION}"
}

termux_step_make_install() {
	export CARGO_BUILD_TARGET=${CARGO_TARGET_NAME}
	export PYO3_CROSS_LIB_DIR=$TERMUX_PREFIX/lib
	export PYTHONPATH=$TERMUX_PREFIX/lib/python${_PYTHON_VERSION}/site-packages

	build-python -m maturin build --release --skip-auditwheel --target $CARGO_BUILD_TARGET

	# Fix wheel name for arm
	if [ "$TERMUX_ARCH" = "arm" ]; then
		mv ./target/wheels/mitmproxy_wireguard-$TERMUX_PKG_VERSION-cp37-abi3-linux_armv7l.whl \
			./target/wheels/mitmproxy_wireguard-$TERMUX_PKG_VERSION-py37-none-any.whl
	fi

	pip install --no-deps ./target/wheels/*.whl --prefix $TERMUX_PREFIX 
}

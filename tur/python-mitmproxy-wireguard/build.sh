TERMUX_PKG_HOMEPAGE=https://github.com/decathorpe/mitmproxy_wireguard
TERMUX_PKG_DESCRIPTION="WireGuard frontend for mitmproxy"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="0.1.23"
TERMUX_PKG_REVISION=3
TERMUX_PKG_SRCURL="https://github.com/decathorpe/mitmproxy_wireguard/archive/refs/tags/$TERMUX_PKG_VERSION.tar.gz"
TERMUX_PKG_SHA256=29eac8ffcb235194b9f1aba9e0fe3e024aa8417427005eabeb30c1870c808b35
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_DEPENDS="libc++, openssl, python"
TERMUX_PKG_PYTHON_COMMON_BUILD_DEPS="wheel"
TERMUX_PKG_PYTHON_CROSS_BUILD_DEPS="maturin"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_UPDATE_TAG_TYPE="newest-tag"

termux_step_pre_configure() {
	_PYTHON_VERSION=$(. $TERMUX_SCRIPTDIR/packages/python/build.sh; echo $_MAJOR_VERSION)

	termux_setup_rust

	LDFLAGS+=" -Wl,--no-as-needed -lpython${_PYTHON_VERSION}"
}

termux_step_make() {
	:
}

termux_step_make_install() {
	export CARGO_BUILD_TARGET=${CARGO_TARGET_NAME}
	export PYO3_CROSS_LIB_DIR=$TERMUX_PREFIX/lib
	export PYTHONPATH=$TERMUX_PREFIX/lib/python${_PYTHON_VERSION}/site-packages
	export ANDROID_API_LEVEL="$TERMUX_PKG_API_LEVEL"

	build-python -m maturin build \
		--target $CARGO_BUILD_TARGET \
		--release --skip-auditwheel \
		--interpreter python${TERMUX_PYTHON_VERSION}

	local _pyver="${TERMUX_PYTHON_VERSION/./}"

	local wheel_arch
	case "$TERMUX_ARCH" in
		aarch64) wheel_arch=arm64_v8a ;;
		arm)     wheel_arch=armeabi_v7a ;;
		x86_64)  wheel_arch=x86_64 ;;
		i686)    wheel_arch=x86 ;;
		*)
			echo "ERROR: Unknown architecture: $TERMUX_ARCH"
			return 1 ;;
	esac

	# Fix wheel name
	mv "target/wheels/mitmproxy_wireguard-${TERMUX_PKG_VERSION}-cp37-abi3-android_${TERMUX_PKG_API_LEVEL}_${wheel_arch}.whl" \
		"target/wheels/mitmproxy_wireguard-${TERMUX_PKG_VERSION}-py${_pyver}-none-any.whl"

	pip install --force-reinstall --no-deps ./target/wheels/*.whl --prefix $TERMUX_PREFIX
}

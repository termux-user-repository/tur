TERMUX_PKG_HOMEPAGE=https://github.com/huggingface/tokenizers
TERMUX_PKG_DESCRIPTION="Fast State-of-the-Art Tokenizers optimized for Research and Production"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="0.22.2"
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL="https://github.com/huggingface/tokenizers/archive/refs/tags/v$TERMUX_PKG_VERSION.tar.gz"
TERMUX_PKG_SHA256=05bffc70e12de04d4c060f9ecd404519aa069e93151c5642e7d731298d9273f6
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_DEPENDS="libc++, python, python-pip"
TERMUX_PKG_PYTHON_COMMON_BUILD_DEPS="wheel"
TERMUX_PKG_PYTHON_CROSS_BUILD_DEPS="maturin"
TERMUX_PKG_BUILD_IN_SRC=true

TERMUX_PKG_RM_AFTER_INSTALL="
lib/python${TERMUX_PYTHON_VERSION}/__pycache__
lib/python${TERMUX_PYTHON_VERSION}/site-packages/pip
"

termux_step_post_get_source() {
	rm -f $TERMUX_PKG_SRCDIR/Makefile
}

termux_step_pre_configure() {
	TERMUX_PKG_SRCDIR+="/bindings/python"
	TERMUX_PKG_BUILDDIR+="/bindings/python"

	termux_setup_rust

	# Tokenizers uses some extra libs that requires `core` crates, but
	# the toolchain provided by rustup doesn't have them (Android is at
	# tier 2). Use nightly toolchain and enable `build-std` feature to
	# build these crates.
	rustup toolchain install nightly
	rustup component add rust-src --toolchain nightly
	echo "nightly" > $TERMUX_PKG_SRCDIR/rust-toolchain
}

termux_step_make() {
	:
}

termux_step_make_install() {
	export CARGO_BUILD_TARGET=${CARGO_TARGET_NAME}
	export PYO3_CROSS_PYTHON_VERSION=$TERMUX_PYTHON_VERSION
	export PYO3_CROSS_LIB_DIR=$TERMUX_PREFIX/lib
	export PYTHONPATH=$TERMUX_PREFIX/lib/python${TERMUX_PYTHON_VERSION}/site-packages
	export ANDROID_API_LEVEL="$TERMUX_PKG_API_LEVEL"

	build-python -m maturin build \
				--target $CARGO_BUILD_TARGET \
				--release --skip-auditwheel \
				--interpreter python${TERMUX_PYTHON_VERSION} \
				-Z build-std

	local _pyver="${TERMUX_PYTHON_VERSION/./}"
	local _tag="cp39-abi3"

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

	# Fix wheel name, although it it built with tag `cp39-abi3`, but it is linked against `python3.x.so`
	# so it will not work on other pythons.
	mv "target/wheels/tokenizers-${TERMUX_PKG_VERSION}-${_tag}-android_${TERMUX_PKG_API_LEVEL}_${wheel_arch}.whl" \
		"target/wheels/tokenizers-${TERMUX_PKG_VERSION}-py${_pyver}-none-any.whl"

	pip install --force-reinstall --no-deps ./target/wheels/*.whl --prefix $TERMUX_PREFIX
}

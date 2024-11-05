TERMUX_PKG_HOMEPAGE=https://github.com/huggingface/tokenizers
TERMUX_PKG_DESCRIPTION="Fast State-of-the-Art Tokenizers optimized for Research and Production"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="0.20.3"
TERMUX_PKG_SRCURL=https://github.com/huggingface/tokenizers/archive/refs/tags/v$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=21e9a235c72e49cafb7ed29829650f6a49f0a951194e1f0168b3b2f547362569
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_DEPENDS="libc++, python, python-pip"
TERMUX_PKG_PYTHON_COMMON_DEPS="wheel"
TERMUX_PKG_PYTHON_BUILD_DEPS="maturin"
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

	export RUSTFLAGS="-C link-args=-L$TERMUX_PREFIX/lib $RUSTFLAGS"

	build-python -m maturin build --release --skip-auditwheel --target $CARGO_BUILD_TARGET -Z build-std

	local _pyver="${TERMUX_PYTHON_VERSION/./}"
	# Fix wheel name for arm
	if [ "$TERMUX_ARCH" = "arm" ]; then
		mv ./target/wheels/tokenizers-$TERMUX_PKG_VERSION-cp$_pyver-cp$_pyver-linux_armv7l.whl \
			./target/wheels/tokenizers-$TERMUX_PKG_VERSION-py$_pyver-none-any.whl
	fi

	pip install --no-deps ./target/wheels/*.whl --prefix $TERMUX_PREFIX
}

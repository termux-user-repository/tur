TERMUX_PKG_HOMEPAGE=https://github.com/huggingface/tokenizers
TERMUX_PKG_DESCRIPTION="Fast State-of-the-Art Tokenizers optimized for Research and Production"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="0.23.1"
TERMUX_PKG_SRCURL="https://github.com/huggingface/tokenizers/archive/refs/tags/v$TERMUX_PKG_VERSION.tar.gz"
TERMUX_PKG_SHA256=aa906ad27ece40261e075e171e4a8873c2c5cfdbb64205170735d425f214c7ef
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_DEPENDS="libc++, python, python-pip"
TERMUX_PKG_PYTHON_COMMON_BUILD_DEPS="'maturin<1.13'"
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_post_get_source() {
	rm -f "$TERMUX_PKG_SRCDIR"/{Makefile,rust-toolchain}
}

_setup_rust_no_explicit_version() {
	: "${CARGO_HOME:="$TERMUX_PKG_TMPDIR/.cargo"}"
	: "${RUSTUP_HOME:="$TERMUX_PKG_TMPDIR/.rustup"}"
	export CARGO_HOME RUSTUP_HOME
	local TERMUX_RUST_VERSION="$(. "${TERMUX_SCRIPTDIR}"/packages/rust/build.sh; echo "${TERMUX_PKG_VERSION}")"
	curl https://sh.rustup.rs -sSfo "${TERMUX_PKG_TMPDIR}"/rustup.sh
	sh "${TERMUX_PKG_TMPDIR}"/rustup.sh -y
	export PATH="${CARGO_HOME}/bin:${PATH}"
	rustup target add "${CARGO_TARGET_NAME}"
}

termux_step_pre_configure() {
	# prevents:
	# error[E0463]: can't find crate for `core`
	# error[E0463]: can't find crate for `std`
	# when building for 32-bit targets
	if [[ "$TERMUX_ON_DEVICE_BUILD" == "false" ]]; then
		_setup_rust_no_explicit_version
	fi

	TERMUX_PKG_SRCDIR+="/bindings/python"
	TERMUX_PKG_BUILDDIR="$TERMUX_PKG_SRCDIR"
	export CARGO_BUILD_TARGET="${CARGO_TARGET_NAME}"
	export PYO3_CROSS_PYTHON_VERSION="$TERMUX_PYTHON_VERSION"
	export PYO3_CROSS_LIB_DIR="$TERMUX_PREFIX/lib"
	export PYTHONPATH="$TERMUX_PREFIX/lib/python${TERMUX_PYTHON_VERSION}/site-packages"
	export ANDROID_API_LEVEL="$TERMUX_PKG_API_LEVEL"
}

termux_step_make() {
	local _maturin="build-python -m maturin"
	if [[ "$TERMUX_ON_DEVICE_BUILD" == "true" ]]; then
		_maturin=maturin
	fi

	$_maturin build \
		--target "$CARGO_BUILD_TARGET" \
		--release \
		--skip-auditwheel \
		--interpreter "python${TERMUX_PYTHON_VERSION}"
}

termux_step_make_install() {
	local native_wheel_arch
	case "$TERMUX_ARCH" in
		aarch64) native_wheel_arch=arm64_v8a ;;
		arm)     native_wheel_arch=armeabi_v7a ;;
		x86_64)  native_wheel_arch=x86_64 ;;
		i686)    native_wheel_arch=x86 ;;
		*)
			echo "ERROR: Unknown architecture: $TERMUX_ARCH"
			return 1 ;;
	esac
	local native_wheel_ext="${TERMUX_PKG_VERSION}-cp310-abi3-android_${ANDROID_API_LEVEL}_${native_wheel_arch}.whl"

	# Fix wheel name, although it it built with tag `cp310-abi3`, but it is linked against `python3.x.so`
	# so it will not work on other pythons.
	local _whl_orig="target/wheels/tokenizers-${native_wheel_ext}"
	local _whl_dest="tokenizers-${TERMUX_PKG_VERSION}-py${TERMUX_PYTHON_VERSION/./}-none-any.whl"
	mv "$_whl_orig" "$_whl_dest"
	pip install \
		--force-reinstall \
		--no-deps \
		"$_whl_dest" \
		--prefix "$TERMUX_PREFIX"
}

TERMUX_PKG_HOMEPAGE=https://github.com/huggingface/xet-core
TERMUX_PKG_DESCRIPTION="Fast transfer of large files with the Hugging Face Hub"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="1.6.0"
TERMUX_PKG_SRCURL="https://github.com/huggingface/xet-core/releases/download/v$TERMUX_PKG_VERSION/hf_xet-$TERMUX_PKG_VERSION.tar.gz"
TERMUX_PKG_SHA256=2e58454a340b3556dfa4972d5451aff4fba8dd42a236600ba1a1d2b1514f0fef
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_DEPENDS="libc++, python"
TERMUX_PKG_PYTHON_COMMON_BUILD_DEPS="'maturin>=1.7,<2.0'"
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_pre_configure() {
	termux_setup_rust

	export CARGO_BUILD_TARGET="${CARGO_TARGET_NAME}"
	export PYO3_CROSS_PYTHON_VERSION="$TERMUX_PYTHON_VERSION"
	export PYO3_CROSS_LIB_DIR="$TERMUX_PREFIX/lib"
	export PYTHONPATH="$TERMUX_PREFIX/lib/python${TERMUX_PYTHON_VERSION}/site-packages"
	export ANDROID_API_LEVEL="$TERMUX_PKG_API_LEVEL"
	export RUSTFLAGS="-C link-arg=-lpython${TERMUX_PYTHON_VERSION} ${RUSTFLAGS:-}"

	# rustls-platform-verifier uses Android JNI by default which fails in CLI environments.
	# Vendor and patch it inside hf_xet (which has its own manifest and lockfile).
	cd "$TERMUX_PKG_SRCDIR/hf_xet"
	# gearhash 0.1.3 erroneously enabled x86_64 SIMD intrinsics on 32-bit x86 (i686),
	# causing compilation failures on i686. Version 0.1.4 fixes x86 gating and adds NEON for aarch64.
	cargo update -p gearhash --precise 0.1.4
	cargo vendor
	find ./vendor -mindepth 1 -maxdepth 1 -type d \
		! -wholename ./vendor/rustls-platform-verifier \
		-exec rm -rf '{}' \;
	find vendor/rustls-platform-verifier -type f -print0 | \
		xargs -0 sed -i \
		-e 's|"android"|"disabling_this_because_it_is_for_building_an_apk"|g' \
		-e "s|ANDROID|DISABLING_THIS_BECAUSE_IT_IS_FOR_BUILDING_AN_APK|g" \
		-e 's|"linux"|"android"|g' \
		-e "s|/etc|$TERMUX_PREFIX/etc|g"
	cat >> Cargo.toml <<-EOF

		[patch.crates-io]
		rustls-platform-verifier = { path = "./vendor/rustls-platform-verifier" }
	EOF
	cd "$TERMUX_PKG_SRCDIR"
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
	local _whl="$(find "$TERMUX_PKG_SRCDIR" -name "hf_xet-${TERMUX_PKG_VERSION}-*.whl" -print -quit)"
	local _whl_dest="hf_xet-${TERMUX_PKG_VERSION}-py${TERMUX_PYTHON_VERSION/./}-none-any.whl"
	mv "$_whl" "$_whl_dest"
	pip install \
		--force-reinstall \
		--no-deps \
		"$_whl_dest" \
		--prefix "$TERMUX_PREFIX"

	# Strip optional test dependencies from METADATA so pip debscripts are not triggered
	sed -i '/^Requires-Dist/d' "$TERMUX_PREFIX/lib/python${TERMUX_PYTHON_VERSION}/site-packages/hf_xet-${TERMUX_PKG_VERSION}.dist-info/METADATA"
}

TERMUX_PKG_HOMEPAGE=https://github.com/pola-rs/polars
TERMUX_PKG_DESCRIPTION="Dataframes powered by a multithreaded, vectorized query engine, written in Rust"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="1.41.2"
TERMUX_PKG_SRCURL="https://github.com/pola-rs/polars/archive/refs/tags/py-$TERMUX_PKG_VERSION.tar.gz"
TERMUX_PKG_SHA256=4459f3ddbde8babb827b140e15920c6e2075959190a6d13428a7aa7ba50d0a95
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_DEPENDS="libc++, python, python-pip, python-polars-runtime-32 | python-polars-runtime-64 | python-polars-runtime-compat"
TERMUX_PKG_PYTHON_COMMON_BUILD_DEPS="build, maturin"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_UPDATE_VERSION_REGEXP="\d+\.\d+\.\d+"
TERMUX_PKG_UPDATE_TAG_TYPE="latest-release-tag"

# Polars doesn't officially support 32-bit Python.
# See https://github.com/pola-rs/polars/issues/10460
TERMUX_PKG_EXCLUDED_ARCHES="arm, i686"

termux_pkg_auto_update() {
	# Get latest release tag:
	local api_url="https://api.github.com/repos/pola-rs/polars/git/refs/tags"
	local latest_refs_tags=$(
		curl -s "$api_url" | jq -r .[].ref | cut -d'/' -f 3 |
			grep "py-" | grep -v -E "(rc)|(alpha)|(beta)"
	)
	if [[ -z "${latest_refs_tags}" ]]; then
		echo "WARN: Unable to get latest refs tags from upstream. Try again later." >&2
		return
	fi
	local latest_version="$(echo "${latest_refs_tags}" | sort -V | tail -n1)"
	termux_pkg_upgrade_version "${latest_version}"
}

termux_step_pre_configure() {
	termux_setup_rust

	cargo vendor
	find ./vendor \
		-mindepth 1 -maxdepth 1 -type d \
		! -wholename ./vendor/arboard \
		! -wholename ./vendor/x11rb-protocol \
		-exec rm -rf '{}' \;

	find vendor/{arboard,x11rb-protocol} -type f -print0 | \
		xargs -0 sed -i \
		-e 's|android|disabling_this_because_it_is_for_building_an_apk|g' \
		-e "s|/tmp|$TERMUX_PREFIX/tmp|g"

	sed -i '/\[patch.crates-io\]/a arboard = { path = "./vendor/arboard" }' Cargo.toml
	sed -i '/\[patch.crates-io\]/a x11rb-protocol = { path = "./vendor/x11rb-protocol" }' Cargo.toml

	export TERMUX_PKG_SRCDIR+="/py-polars"
	export TERMUX_PKG_BUILDDIR="$TERMUX_PKG_SRCDIR"
	export PYTHONPATH="$TERMUX_PREFIX/lib/python${TERMUX_PYTHON_VERSION}/site-packages"
	export CARGO_BUILD_TARGET="${CARGO_TARGET_NAME}"
	export ANDROID_API_LEVEL="$TERMUX_PKG_API_LEVEL"
	export PYO3_CROSS_LIB_DIR="$TERMUX_PREFIX/lib"
	export RUSTC_BOOTSTRAP=1
	LDFLAGS+=" -Wl,--no-as-needed,-lpython${TERMUX_PYTHON_VERSION},--as-needed"
}

termux_step_make() {
	local _maturin="build-python -m maturin"
	if [[ "$TERMUX_ON_DEVICE_BUILD" == "true" ]]; then
		_maturin=maturin
	fi

	python -m build -w -n -x
	for runtime in 32 64 compat; do
		$_maturin build \
			--target "$CARGO_BUILD_TARGET" \
			--release \
			--skip-auditwheel \
			--interpreter "python${TERMUX_PYTHON_VERSION}" \
			--manifest-path "runtime/polars-runtime-$runtime/Cargo.toml"
	done
}

termux_step_make_install() {
	pip install \
		--force-reinstall \
		--no-deps \
		"dist/polars-${TERMUX_PKG_VERSION}-py3-none-any.whl" \
		--prefix "$TERMUX_PREFIX"

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

	local native_wheel_type
	for native_wheel_type in 32 64 compat; do
		# Avoid 'ERROR: polars_runtime_32-1.38.1-cp310-abi3-android_24_arm64_v8a.whl is not a supported wheel on this platform.'
		local _whl_orig="$(realpath ../target/wheels/polars_runtime_"${native_wheel_type}-${native_wheel_ext}")"
		local _whl_dest="polars_runtime_${native_wheel_type}-${TERMUX_PKG_VERSION}-py${TERMUX_PYTHON_VERSION/./}-none-any.whl"
		mv "$_whl_orig" "$_whl_dest"
		pip install \
			--force-reinstall \
			--no-deps \
			"$_whl_dest" \
			--prefix "$TERMUX_PREFIX"
	done
}

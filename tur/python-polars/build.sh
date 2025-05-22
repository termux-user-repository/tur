TERMUX_PKG_HOMEPAGE=https://github.com/pola-rs/polars
TERMUX_PKG_DESCRIPTION="Dataframes powered by a multithreaded, vectorized query engine, written in Rust"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="1.30.0"
TERMUX_PKG_SRCURL=https://github.com/pola-rs/polars/releases/download/py-$TERMUX_PKG_VERSION/polars-$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=dfe94ae84a5efd9ba74e616e3e125b24ca155494a931890a8f17480737c4db45
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_DEPENDS="libc++, python"
TERMUX_PKG_PYTHON_COMMON_DEPS="wheel"
TERMUX_PKG_PYTHON_BUILD_DEPS="maturin"
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
	termux_setup_cmake
	termux_setup_rust

	: "${CARGO_HOME:=$HOME/.cargo}"
	export CARGO_HOME

	cargo fetch --target "${CARGO_TARGET_NAME}"

	# Dummy CMake toolchain file to workaround build error:
	# CMake Error at /home/builder/.termux-build/_cache/cmake-3.30.3/share/cmake-3.30/Modules/Platform/Android-Determine.cmake:218 (message):
	# Android: Neither the NDK or a standalone toolchain was found.
	export TARGET_CMAKE_TOOLCHAIN_FILE="${TERMUX_PKG_BUILDDIR}/android.toolchain.cmake"
	touch "${TERMUX_PKG_BUILDDIR}/android.toolchain.cmake"

	cargo vendor
	find ./vendor \
		-mindepth 1 -maxdepth 1 -type d \
		! -wholename ./vendor/arboard \
		-exec rm -rf '{}' \;

	patch --silent -p1 \
		-d ./vendor/arboard/ \
		< "$TERMUX_PKG_BUILDER_DIR"/arboard-dummy-platform.diff

	sed -i 's|^\(\[patch\.crates-io\]\)$|\1\narboard = { path = "\./vendor/arboard" }|g' \
		Cargo.toml

	LDFLAGS+=" -Wl,--no-as-needed,-lpython${TERMUX_PYTHON_VERSION},--as-needed"
}

termux_step_make() {
	export CARGO_BUILD_TARGET=${CARGO_TARGET_NAME}
	export PYO3_CROSS_LIB_DIR=$TERMUX_PREFIX/lib
	export PYTHONPATH=$TERMUX_PREFIX/lib/python${TERMUX_PYTHON_VERSION}/site-packages

	build-python -m maturin build \
				--target $CARGO_BUILD_TARGET \
				--release --skip-auditwheel \
				--interpreter python${TERMUX_PYTHON_VERSION}
}

termux_step_make_install() {
	pip install --no-deps ./target/wheels/*.whl --prefix $TERMUX_PREFIX
}

termux_step_post_make_install() {
	# This is not necessary, and may cause file conflict
	rm -f $PYTHONPATH/rust-toolchain.toml

	# Remove the vendor sources to save space
	rm -rf "$TERMUX_PKG_SRCDIR"/vendor
}

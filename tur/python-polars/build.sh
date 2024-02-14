TERMUX_PKG_HOMEPAGE=https://github.com/pola-rs/polars
TERMUX_PKG_DESCRIPTION="Dataframes powered by a multithreaded, vectorized query engine, written in Rust"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="0.20.8"
TERMUX_PKG_SRCURL=https://github.com/pola-rs/polars/releases/download/py-$TERMUX_PKG_VERSION/polars-$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=a34f6ce1c5469872b291aaf90467e632e81f92dec6c2e18136bc40cd92877411
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_DEPENDS="libc++, python"
TERMUX_PKG_PYTHON_COMMON_DEPS="wheel"
TERMUX_PKG_PYTHON_BUILD_DEPS="maturin"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_UPDATE_VERSION_REGEXP="\d+\.\d+\.\d+"
TERMUX_PKG_UPDATE_TAG_TYPE="latest-release-tag"

# Polars doesn't officially support 32-bit Python.
# See https://github.com/pola-rs/polars/issues/10460
TERMUX_PKG_BLACKLISTED_ARCHES="arm, i686"

termux_pkg_auto_update() {
	# Get latest release tag:
	local api_url="https://api.github.com/repos/pola-rs/polars/git/refs/tags"
	local latest_refs_tags=$(curl -s "${api_url}" | jq .[].ref | grep -oP py-${TERMUX_PKG_UPDATE_VERSION_REGEXP} | sort -V)
	if [[ -z "${latest_refs_tags}" ]]; then
		echo "WARN: Unable to get latest refs tags from upstream. Try again later." >&2
		return
	fi

	local latest_version="$(echo "${latest_refs_tags}" | tail -n1 | cut -c 4-)"
	if [[ "${latest_version}" == "${TERMUX_PKG_VERSION}" ]]; then
		echo "INFO: No update needed. Already at version '${TERMUX_PKG_VERSION}'."
		return
	fi

	termux_pkg_upgrade_version "${latest_version}"
}

termux_step_pre_configure() {
	_PYTHON_VERSION=$(. $TERMUX_SCRIPTDIR/packages/python/build.sh; echo $_MAJOR_VERSION)

	termux_setup_cmake
	termux_setup_rust

	: "${CARGO_HOME:=$HOME/.cargo}"
	export CARGO_HOME

	rm -rf $CARGO_HOME/registry/src/*/cmake-*
	rm -rf $CARGO_HOME/registry/src/*/jemalloc-sys-*
	cargo fetch --target "${CARGO_TARGET_NAME}"

	local p="cmake-0.1.50-src-lib.rs.diff"
	local d
	for d in $CARGO_HOME/registry/src/*/cmake-*; do
		patch --silent -p1 -d ${d} \
			< "$TERMUX_PKG_BUILDER_DIR/${p}"
	done

	p="jemalloc-sys-0.5.4+5.3.0-patched-src-lib.rs.diff"
	for d in $CARGO_HOME/registry/src/*/jemalloc-sys-*; do
		patch --silent -p1 -d ${d} < "$TERMUX_PKG_BUILDER_DIR/${p}"
	done

	local _CARGO_TARGET_LIBDIR="target/${CARGO_TARGET_NAME}/release/deps"
	mkdir -p $_CARGO_TARGET_LIBDIR

	mv $TERMUX_PREFIX/lib/libz.so.1{,.tmp}
	mv $TERMUX_PREFIX/lib/libz.so{,.tmp}

	ln -sfT $(readlink -f $TERMUX_PREFIX/lib/libz.so.1.tmp) \
		$_CARGO_TARGET_LIBDIR/libz.so.1
	ln -sfT $(readlink -f $TERMUX_PREFIX/lib/libz.so.tmp) \
		$_CARGO_TARGET_LIBDIR/libz.so

	LDFLAGS+=" -Wl,--no-as-needed -lpython${_PYTHON_VERSION}"
}

termux_step_make() {
	:
}

termux_step_make_install() {
	export CARGO_BUILD_TARGET=${CARGO_TARGET_NAME}
	export PYO3_CROSS_LIB_DIR=$TERMUX_PREFIX/lib
	export PYTHONPATH=$TERMUX_PREFIX/lib/python${_PYTHON_VERSION}/site-packages

	build-python -m maturin build --release --skip-auditwheel --target $CARGO_BUILD_TARGET

	pip install --no-deps ./target/wheels/*.whl --prefix $TERMUX_PREFIX 
}

termux_step_post_make_install() {
	mv $TERMUX_PREFIX/lib/libz.so.1{.tmp,}
	mv $TERMUX_PREFIX/lib/libz.so{.tmp,}

	rm -f $PYTHONPATH/rust-toolchain.toml
}

termux_step_post_massage() {
	rm -f lib/libz.so.1
	rm -f lib/libz.so
}

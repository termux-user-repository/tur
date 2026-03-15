TERMUX_PKG_HOMEPAGE=https://github.com/ijl/orjson
TERMUX_PKG_DESCRIPTION="Fast, correct Python JSON library supporting dataclasses, datetimes, and numpy"
TERMUX_PKG_LICENSE="Apache-2.0, MIT"
TERMUX_PKG_MAINTAINER="Shaheen <shaheenvsa@gmail.com>"
TERMUX_PKG_VERSION=3.10.18
TERMUX_PKG_SRCURL=https://files.pythonhosted.org/packages/source/o/orjson/orjson-3.10.18.tar.gz
TERMUX_PKG_SHA256=e8da3947d92123eda795b68228cafe2724815621fe35e8e320a9e9593a4bcd53
TERMUX_PKG_DEPENDS="libc++, python"
TERMUX_PKG_PYTHON_COMMON_BUILD_DEPS="maturin"
TERMUX_PKG_EXCLUDED_ARCHES="arm, i686"

termux_step_pre_configure() {
    termux_setup_rust
    cargo fetch --target "${CARGO_TARGET_NAME}"
}

termux_step_make() {
    rustup target add aarch64-linux-android

    pip install maturin --quiet --break-system-packages

    cd "$TERMUX_PKG_SRCDIR"

    PYO3_CROSS=1 \
    PYO3_CROSS_LIB_DIR="$TERMUX_PREFIX/lib" \
    PYO3_CROSS_PYTHON_VERSION="${TERMUX_PYTHON_VERSION}" \
    CARGO_TARGET_DIR="$TERMUX_PKG_BUILDDIR/target" \
    ANDROID_API_LEVEL="${TERMUX_PKG_API_LEVEL:-24}" \
    maturin build \
        --release \
        --target "${CARGO_TARGET_NAME}" \
        --interpreter "python${TERMUX_PYTHON_VERSION}" \
        --out "$TERMUX_PKG_BUILDDIR/wheels"

    local _whl
    _whl=$(find "$TERMUX_PKG_BUILDDIR/wheels" -name "orjson-*.whl" | head -n1)

    if [[ -z "$_whl" ]]; then
        echo "ERROR: No wheel found after maturin build"
        return 1
    fi

    local _pyver="${TERMUX_PYTHON_VERSION/./}"
    mv "$_whl" "$TERMUX_PKG_BUILDDIR/wheels/orjson-${TERMUX_PKG_VERSION}-py${_pyver}-none-any.whl"
    echo "Wheel renamed to: orjson-${TERMUX_PKG_VERSION}-py${_pyver}-none-any.whl"
}

termux_step_make_install() {
    pip install \
        --force-reinstall \
        --no-deps \
        --prefix="$TERMUX_PREFIX" \
        "$TERMUX_PKG_BUILDDIR/wheels"/orjson-*.whl
}


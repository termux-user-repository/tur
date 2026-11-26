TERMUX_PKG_HOMEPAGE=https://github.com/ijl/orjson
TERMUX_PKG_DESCRIPTION="Fast, correct Python JSON library supporting dataclasses, datetimes, and numpy"
TERMUX_PKG_LICENSE="Apache-2.0, MIT"
TERMUX_PKG_MAINTAINER="Shaheen <shaheenvsa@gmail.com>"
TERMUX_PKG_VERSION=3.10.18
TERMUX_PKG_SRCURL=https://files.pythonhosted.org/packages/source/o/orjson/orjson-3.10.18.tar.gz
TERMUX_PKG_SHA256=e8da3947d92123eda795b68228cafe2724815621fe35e8e320a9e9593a4bcd53
TERMUX_PKG_DEPENDS="python"
TERMUX_PKG_BUILD_DEPENDS="python-pip"
TERMUX_PKG_API_LEVEL=24

termux_step_make() {
    termux_setup_rust
    rustup target add aarch64-linux-android

    cd "$TERMUX_PKG_SRCDIR"
    pip install maturin --quiet --break-system-packages

    MATURIN_BIN=$(find /home/builder/.local/bin /usr/local/bin -name "maturin" 2>/dev/null | head -1)

    PYO3_CROSS=1 \
    PYO3_CROSS_LIB_DIR="$TERMUX_PREFIX/lib" \
    PYO3_CROSS_PYTHON_VERSION="3.13" \
    CARGO_TARGET_DIR="$TERMUX_PKG_BUILDDIR/target" \
    ANDROID_API_LEVEL=24 \
    "$MATURIN_BIN" build \
        --release \
        --target aarch64-linux-android \
        --strip \
        --out "$TERMUX_PKG_BUILDDIR/wheels" \
        -i python3
}

termux_step_make_install() {
    WHEEL=$(find "$TERMUX_PKG_BUILDDIR/wheels" -name "orjson-*.whl" | head -1)
    echo "Installing wheel: $WHEEL"
    unzip -o "$WHEEL" -d "$TERMUX_PREFIX/lib/python3.13/site-packages/"
}

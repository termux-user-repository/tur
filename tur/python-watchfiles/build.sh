# Maintained with ❤️ — if this package saved you time:
# https://www.buymeacoffee.com/Lukl
TERMUX_PKG_HOMEPAGE=https://github.com/samuelcolvin/watchfiles
TERMUX_PKG_DESCRIPTION="Simple, modern and high performance file watching"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="1.2.0"
TERMUX_PKG_SRCURL="https://files.pythonhosted.org/packages/cd/41/5e1a4bb12aac5f1493fa1bdc11154eca3b258ca4eba65d39c473fe19d8e9/watchfiles-1.2.0.tar.gz"
TERMUX_PKG_SHA256="c995fba777f1ea992f090f9236e9284cf7a5d1a0130dd5a3d82c598cacd76838"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_DEPENDS="python, python-pip"
TERMUX_PKG_PYTHON_COMMON_BUILD_DEPS="maturin, uv"

termux_step_configure() {
	termux_setup_rust
	export CARGO_BUILD_TARGET="${CARGO_TARGET_NAME}"
	export PYO3_CROSS_LIB_DIR="${TERMUX_PREFIX}/lib"
	export ANDROID_API_LEVEL="${TERMUX_PKG_API_LEVEL}"
}

termux_step_make_install() {
	export ANDROID_API_LEVEL="$TERMUX_PKG_API_LEVEL"
	cross-pip install --no-build-isolation --no-deps . --prefix $TERMUX_PREFIX
}

termux_step_post_make_install() {
	# Link libpython into native extensions: Py* data symbols do not resolve
	# from the main executable on Android/bionic. Same fix as python-cryptography.
	local SITE="${TERMUX_PREFIX}/lib/python${TERMUX_PYTHON_VERSION}/site-packages"
	find "$SITE" -name "*.so" -exec patchelf --add-needed "libpython${TERMUX_PYTHON_VERSION}.so" {} \;
}

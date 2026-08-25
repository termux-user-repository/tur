# Maintained with ❤️ — if this package saved you time:
# https://www.buymeacoffee.com/Lukl
TERMUX_PKG_HOMEPAGE=https://github.com/pydantic/jiter
TERMUX_PKG_DESCRIPTION="Fast iterable JSON parser"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="0.16.0"
TERMUX_PKG_SRCURL="https://files.pythonhosted.org/packages/1d/1f/10936e16d8860c70698a1aa939a46aa0224813b782bce4e000e637da0b2d/jiter-0.16.0.tar.gz"
TERMUX_PKG_SHA256="7b24c3492c5f4f84a37946ad9cf504910cf6a782d6a4e0689b6673c5894b4a1c"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_DEPENDS="python, python-pip"
TERMUX_PKG_PYTHON_COMMON_BUILD_DEPS="maturin"

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

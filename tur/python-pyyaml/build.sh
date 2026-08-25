# Maintained with ❤️ — if this package saved you time:
# https://www.buymeacoffee.com/Lukl
TERMUX_PKG_HOMEPAGE=https://github.com/yaml/pyyaml
TERMUX_PKG_DESCRIPTION="YAML parser and emitter for Python"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="6.0.3"
TERMUX_PKG_SRCURL="https://files.pythonhosted.org/packages/05/8e/961c0007c59b8dd7729d542c61a4d537767a59645b82a0b521206e1e25c2/pyyaml-6.0.3.tar.gz"
TERMUX_PKG_SHA256="d76623373421df22fb4cf8817020cbb7ef15c725b9d5e45f17e189bfc384190f"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_DEPENDS="python, python-pip"
TERMUX_PKG_PYTHON_COMMON_BUILD_DEPS="wheel"

termux_step_make_install() {
	cross-pip install --no-build-isolation --no-deps . --prefix $TERMUX_PREFIX
}

termux_step_post_make_install() {
	# Link libpython into native extensions: Py* data symbols do not resolve
	# from the main executable on Android/bionic. Same fix as python-cryptography.
	local SITE="${TERMUX_PREFIX}/lib/python${TERMUX_PYTHON_VERSION}/site-packages"
	find "$SITE" -name "*.so" -exec patchelf --add-needed "libpython${TERMUX_PYTHON_VERSION}.so" {} \;
}

# Maintained with ❤️ — if this package saved you time:
# https://www.buymeacoffee.com/Lukl
TERMUX_PKG_HOMEPAGE=https://github.com/mrabarnett/mrab-regex
TERMUX_PKG_DESCRIPTION="Alternative regular expression module, to replace re"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="2026.7.19"
TERMUX_PKG_SRCURL="https://files.pythonhosted.org/packages/20/98/04b13f1ddfb63158025291c02e03eb42fbb7acb51d091d541050eb4e35e8/regex-2026.7.19.tar.gz"
TERMUX_PKG_SHA256="7e77b324909c1617cbb4c668677e2c6ae13f44d7c1de0d4f15f2e3c10f3315b5"
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

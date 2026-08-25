# Maintained with ❤️ — if this package saved you time:
# https://www.buymeacoffee.com/Lukl
TERMUX_PKG_HOMEPAGE=https://github.com/pallets/markupsafe
TERMUX_PKG_DESCRIPTION="Safely add untrusted strings to HTML/XML markup"
TERMUX_PKG_LICENSE="BSD 3-Clause"
TERMUX_PKG_LICENSE_FILE="LICENSE.txt"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="3.0.3"
TERMUX_PKG_SRCURL="https://files.pythonhosted.org/packages/7e/99/7690b6d4034fffd95959cbe0c02de8deb3098cc577c67bb6a24fe5d7caa7/markupsafe-3.0.3.tar.gz"
TERMUX_PKG_SHA256="722695808f4b6457b320fdc131280796bdceb04ab50fe1795cd540799ebe1698"
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

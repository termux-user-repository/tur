TERMUX_PKG_HOMEPAGE=https://ameva.pro/lib/tts/
TERMUX_PKG_DESCRIPTION="On-device 4-tier Text-to-Speech synthesis framework"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@uno-km"
TERMUX_PKG_VERSION="2.0.3"
TERMUX_PKG_SRCURL="https://github.com/uno-km/amv-tts/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=54b1e1ddf2d0a5598dae931542ee2bae236b69ec9eda747716d85eb7ab52ae00
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_TAG_TYPE="newest-tag"
TERMUX_PKG_DEPENDS="python, python-numpy"
TERMUX_PKG_SETUP_PYTHON=true
TERMUX_PKG_PYTHON_COMMON_BUILD_DEPS="setuptools, wheel"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_PLATFORM_INDEPENDENT=true

termux_step_make_install() {
	pip install --no-deps --no-build-isolation . --prefix="$TERMUX_PREFIX"
}

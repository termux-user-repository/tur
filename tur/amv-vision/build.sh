TERMUX_PKG_HOMEPAGE=https://ameva.pro/lib/vision/
TERMUX_PKG_DESCRIPTION="On-device computer vision and VLM multimodal inference CLI"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@uno-km"
TERMUX_PKG_VERSION="2.0.2"
TERMUX_PKG_SRCURL="https://github.com/uno-km/amv-vision/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=2743fd57153b8e032b5e7faf1fb1fef78eba650f96fb8136756166b51198a6f4
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_TAG_TYPE="newest-tag"
TERMUX_PKG_DEPENDS="amv-llamacpp, python, python-numpy, python-pillow"
TERMUX_PKG_SETUP_PYTHON=true
TERMUX_PKG_PYTHON_COMMON_BUILD_DEPS="setuptools, wheel"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_PLATFORM_INDEPENDENT=true

termux_step_make_install() {
	pip install --no-deps --no-build-isolation . --prefix="$TERMUX_PREFIX"
}

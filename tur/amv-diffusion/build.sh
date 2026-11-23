TERMUX_PKG_HOMEPAGE=https://ameva.pro/lib/diffusion/
TERMUX_PKG_DESCRIPTION="On-device Stable Diffusion and DiT image generation runtime"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@uno-km"
TERMUX_PKG_VERSION="3.0.3"
TERMUX_PKG_SRCURL="https://github.com/uno-km/amv-diffusion/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=c26190c599d5bc2f52fa95d149d09eefb0bf11475235e5f2228755947e9d0f07
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_TAG_TYPE="newest-tag"
TERMUX_PKG_DEPENDS="python"
TERMUX_PKG_SETUP_PYTHON=true
TERMUX_PKG_PYTHON_COMMON_BUILD_DEPS="setuptools, wheel"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_PLATFORM_INDEPENDENT=true

termux_step_make_install() {
	pip install --no-deps --no-build-isolation . --prefix="$TERMUX_PREFIX"
}

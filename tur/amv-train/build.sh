TERMUX_PKG_HOMEPAGE=https://ameva.pro/lib/train/
TERMUX_PKG_DESCRIPTION="On-device deep learning and LoRA fine-tuning framework"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@uno-km"
TERMUX_PKG_VERSION="3.0.3"
TERMUX_PKG_SRCURL="https://github.com/uno-km/amv-train/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=911daff4b11519a04f57d0b842307e6f56115e7f3620445bc2387955a0070e15
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_TAG_TYPE="newest-tag"
TERMUX_PKG_DEPENDS="python, python-pip"
TERMUX_PKG_SETUP_PYTHON=true
TERMUX_PKG_PYTHON_COMMON_BUILD_DEPS="setuptools, wheel"
TERMUX_PKG_PYTHON_TARGET_DEPS="'amv-component-sdk>=0.1.0,<2.0'"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_PLATFORM_INDEPENDENT=true

termux_step_make_install() {
	pip install --no-deps --no-build-isolation . --prefix="$TERMUX_PREFIX"
}

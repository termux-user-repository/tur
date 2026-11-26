TERMUX_PKG_HOMEPAGE=https://ameva.pro/lib/aichain/
TERMUX_PKG_DESCRIPTION="Zero-dependency AI chaining and autonomous agent framework"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@uno-km"
TERMUX_PKG_VERSION="2.0.2"
TERMUX_PKG_SRCURL="https://github.com/uno-km/amv-aichain/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=bd3effd12d5a9cb87ef6a2cf267aabd3a4596a63d708ac1ecdc10174cef94f66
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_TAG_TYPE="newest-tag"
TERMUX_PKG_DEPENDS="python, python-pip"
TERMUX_PKG_SETUP_PYTHON=true
TERMUX_PKG_PYTHON_COMMON_BUILD_DEPS="setuptools, wheel"
TERMUX_PKG_PYTHON_TARGET_DEPS="'amv-runtime>=2.9.0', 'amv-component-sdk>=0.1.0,<2.0'"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_PLATFORM_INDEPENDENT=true

termux_step_make_install() {
	pip install --no-deps --no-build-isolation . --prefix="$TERMUX_PREFIX"
}

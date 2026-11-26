TERMUX_PKG_HOMEPAGE=https://ameva.pro/lib/bitnet/
TERMUX_PKG_DESCRIPTION="BitNet 1.58-bit on-device LLM inference SDK and CLI"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@uno-km"
TERMUX_PKG_VERSION="3.0.3"
TERMUX_PKG_SRCURL="https://github.com/uno-km/amv-bitnet/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=1e3c18493a8d04f33014c2fe39954e0651365216cb408873f90af54e4e2aeee3
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_TAG_TYPE="newest-tag"
TERMUX_PKG_DEPENDS="python, python-pip"
TERMUX_PKG_SETUP_PYTHON=true
TERMUX_PKG_PYTHON_COMMON_BUILD_DEPS="setuptools, wheel"
TERMUX_PKG_PYTHON_TARGET_DEPS="'requests>=2.28.0'"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_PLATFORM_INDEPENDENT=true

termux_step_make_install() {
	pip install --no-deps --no-build-isolation . --prefix="$TERMUX_PREFIX"
}

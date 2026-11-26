TERMUX_PKG_HOMEPAGE=https://ameva.pro/lib/stt/
TERMUX_PKG_DESCRIPTION="On-device Speech-to-Text and neural diarization CLI framework"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@uno-km"
TERMUX_PKG_VERSION="3.0.2"
TERMUX_PKG_SRCURL="https://github.com/uno-km/amv-stt/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=107769bad7c33beccf3797fd3776d5fc204c90b33006f3f0ecc31a6a09795210
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_TAG_TYPE="newest-tag"
TERMUX_PKG_DEPENDS="libffi, python, python-pip, vulkan-loader-android"
TERMUX_PKG_SETUP_PYTHON=true
TERMUX_PKG_PYTHON_COMMON_BUILD_DEPS="setuptools, wheel"
TERMUX_PKG_PYTHON_TARGET_DEPS="'cffi>=1.15.0', 'srt>=3.5.0'"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_PLATFORM_INDEPENDENT=true

termux_step_make_install() {
	pip install --no-deps --no-build-isolation . --prefix="$TERMUX_PREFIX"
}

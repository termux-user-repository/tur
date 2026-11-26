TERMUX_PKG_HOMEPAGE=https://ameva.pro/lib/llamacpp/
TERMUX_PKG_DESCRIPTION="On-device GGUF LLM runtime, model manager, and OpenAI server"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@uno-km"
TERMUX_PKG_VERSION="2.0.2"
TERMUX_PKG_SRCURL="https://github.com/uno-km/amv-llamacpp/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=44e7220831f127b755349056255eb282a102a94ee192b33054264e4243b28aa1
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_TAG_TYPE="newest-tag"
TERMUX_PKG_DEPENDS="python, python-pip"
TERMUX_PKG_SETUP_PYTHON=true
TERMUX_PKG_PYTHON_COMMON_BUILD_DEPS="setuptools, wheel"
TERMUX_PKG_PYTHON_TARGET_DEPS="'requests>=2.31.0', 'tqdm>=4.66.0'"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_PLATFORM_INDEPENDENT=true

termux_step_make_install() {
	pip install --no-deps --no-build-isolation . --prefix="$TERMUX_PREFIX"
}

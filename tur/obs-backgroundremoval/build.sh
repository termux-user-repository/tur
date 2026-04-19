TERMUX_PKG_HOMEPAGE="https://github.com/royshil/obs-backgroundremoval"
TERMUX_PKG_DESCRIPTION="AI background removal for OBS Studio using ONNX"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="1.4.0"
TERMUX_PKG_SRCURL="git+https://github.com/royshil/obs-backgroundremoval.git"
TERMUX_PKG_GIT_BRANCH="${TERMUX_PKG_VERSION}"
TERMUX_PKG_DEPENDS="obs-studio, onnxruntime, opencv"

TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DCMAKE_CXX_SCAN_FOR_MODULES=OFF
-DOpenCV_DIR=${TERMUX_PREFIX}/lib/cmake/opencv4
-Dobs_DIR=${TERMUX_PREFIX}/lib/cmake/libobs
"

termux_step_post_get_source() {
	git submodule update --init --recursive
}

termux_step_pre_configure() {
	CXXFLAGS+=" -I${TERMUX_PREFIX}/include/opencv4"
}

termux_step_create_debscripts() {
	echo "X-Display-Name: OBS Background Removal" >> control
}

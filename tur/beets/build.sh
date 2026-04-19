TERMUX_PKG_HOMEPAGE=https://beets.io
TERMUX_PKG_DESCRIPTION="The music geek's media organizer"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@mrtnvgr"
TERMUX_PKG_VERSION="2.9.0"
TERMUX_PKG_SRCURL="https://github.com/beetbox/beets/releases/download/v${TERMUX_PKG_VERSION}/beets-${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=3669354d0198d5b7a0a74bc6fbdcc2caaccc9cd6e02d77860310adf9b131a141
TERMUX_PKG_DEPENDS="cmake, python, python-pip, python-numpy, rust"
TERMUX_PKG_SETUP_PYTHON=true
TERMUX_PKG_PYTHON_RUNTIME_DEPS="--no-build-isolation"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_create_debscripts() {
	cat <<- POSTINST_EOF > ./postinst
	#!$TERMUX_PREFIX/bin/bash
	export ANDROID_API_LEVEL=$TERMUX_PKG_API_LEVEL
	LDFLAGS="-lpython$TERMUX_PYTHON_VERSION" MATHLIB="m" pip install --upgrade maturin Cython
	POSTINST_EOF
}

TERMUX_PKG_HOMEPAGE=http://dlib.net/
TERMUX_PKG_DESCRIPTION="a modern C++ toolkit containing machine learning algorithms and tools for creating complex software in C++ to solve real world problems"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="19.24.6"
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=https://github.com/davisking/dlib/archive/refs/tags/v$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=22513c353ec9c153300c394050c96ca9d088e02966ac0f639e989e50318c82d6
TERMUX_PKG_DEPENDS="libx11, libxcb, libopenblas, python"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	termux_setup_cmake
	termux_setup_ninja

	if $TERMUX_ON_DEVICE_BUILD; then
		termux_error_exit "Package '$TERMUX_PKG_NAME' is not available for on-device builds."
	fi

	termux_setup_python_pip

	LDFLAGS+=" -lpython${TERMUX_PYTHON_VERSION}"
	build-pip install wheel looseversion
}

termux_step_configure() {
	if [ "$TERMUX_CMAKE_BUILD" = Ninja ]; then
		MAKE_PROGRAM_PATH=$(command -v ninja)
	else
		MAKE_PROGRAM_PATH=$(command -v make)
	fi
	BUILD_TYPE=Release
	test "$TERMUX_DEBUG_BUILD" == "true" && BUILD_TYPE=Debug
	CMAKE_PROC=$TERMUX_ARCH
	test $CMAKE_PROC == "arm" && CMAKE_PROC='armv7-a'
	CPPFLAGS+=" -DPNG_ARM_NEON_OPT=0"
}

termux_step_make() {
	python setup.py bdist_wheel \
			-G $TERMUX_CMAKE_BUILD \
			--set CMAKE_AR="$(command -v $AR)" \
			--set CMAKE_UNAME="$(command -v uname)" \
			--set CMAKE_RANLIB="$(command -v $RANLIB)" \
			--set CMAKE_STRIP="$(command -v $STRIP)" \
			--set CMAKE_BUILD_TYPE=$BUILD_TYPE \
			--set CMAKE_C_FLAGS="$CFLAGS $CPPFLAGS" \
			--set CMAKE_CXX_FLAGS="$CXXFLAGS $CPPFLAGS" \
			--set CMAKE_FIND_ROOT_PATH=$TERMUX_PREFIX \
			--set CMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER \
			--set CMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY \
			--set CMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY \
			--set CMAKE_INSTALL_PREFIX=$TERMUX_PREFIX \
			--set CMAKE_INSTALL_LIBDIR=$TERMUX_PREFIX/lib \
			--set CMAKE_MAKE_PROGRAM=$MAKE_PROGRAM_PATH \
			--set CMAKE_SKIP_INSTALL_RPATH=ON \
			--set CMAKE_USE_SYSTEM_LIBRARIES=True \
			--set BUILD_TESTING=OFF \
			--set CMAKE_CROSSCOMPILING=True \
			--set CMAKE_SYSTEM_NAME=Linux \
			--set SSE4_IS_AVAILABLE_ON_HOST=0 \
			--set AVX_IS_AVAILABLE_ON_HOST=0 \
			--set ARM_NEON_IS_AVAILABLE=0
}

termux_step_make_install() {
	export PYTHONPATH=$TERMUX_PREFIX/lib/python${TERMUX_PYTHON_VERSION}/site-packages
	pip install --no-deps ./dist/*.whl --prefix=$TERMUX_PREFIX
}

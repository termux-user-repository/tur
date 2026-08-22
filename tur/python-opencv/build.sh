#!/bin/bash

TERMUX_PKG_NAME="python-opencv"
TERMUX_PKG_VERSION="5.0.0"
TERMUX_PKG_REVISION=0
TERMUX_PKG_DESCRIPTION="Open Source Computer Vision Library"
TERMUX_PKG_HOMEPAGE="https://opencv.org/"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="わたあめえ wataamee777@gmail.com"

TERMUX_PKG_SRCURL="https://github.com/opencv/opencv/archive/refs/tags/{TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256="e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
TERMUX_PKG_DEPENDS="python, numpy, libjpeg-turbo, libpng, libtiff, openjpeg"
TERMUX_PKG_BUILD_DEPENDS="python-pip"
TERMUX_PKG_FORCE_CMAKE=true

termux_step_make() {
	local _PYTHON_VERSION=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')

	cmake . \
		"${TERMUX_CMAKE_ARGS[@]}" \
		-DCMAKE_SYSTEM_NAME=Linux \
		-DCMAKE_INSTALL_PREFIX="$TERMUX_PREFIX" \
		-DBUILD_SHARED_LIBS=ON \
		-DCPU_BASELINE=NEON \
		-DENABLE_NEON=ON \
		-DBUILD_EXAMPLES=OFF \
		-DBUILD_TESTS=OFF \
		-DBUILD_PERF_TESTS=OFF \
		-DBUILD_opencv_apps=OFF \
		-DBUILD_opencv_java=OFF \
		-DOPENCV_GENERATE_PKGCONFIG=ON \
		-DBUILD_opencv_python3=ON \
		-DPYTHON3_NUMPY_INCLUDE_DIRS="$TERMUX_PREFIX/lib/python${_PYTHON_VERSION}/site-packages/numpy/core/include" \
		-DPYTHON3_INCLUDE_PATH="$TERMUX_PREFIX/include/python${_PYTHON_VERSION}" \
		-DPYTHON3_LIBRARIES="$TERMUX_PREFIX/lib/libpython${_PYTHON_VERSION}.so"

	make -j$TERMUX_PKG_MAKE_PROCESSES
}

termux_step_make_install() {
	local _PYTHON_VERSION=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
	local TARGET_DIR="$TERMUX_PREFIX/lib/python${_PYTHON_VERSION}/site-packages"

	install -Dm755 -t "$TARGET_DIR" lib/python3/cv2*.so
}

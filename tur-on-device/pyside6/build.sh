TERMUX_PKG_HOMEPAGE=https://doc.qt.io/qtforpython-6/
TERMUX_PKG_DESCRIPTION="Official Python bindings for Qt6"
# multiple licenses
TERMUX_PKG_LICENSE="GPL-3.0-only"
TERMUX_PKG_LICENSE_FILE="
LICENSES/GPL-3.0-only.txt
LICENSES/Qt-GPL-exception-1.0.txt
"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="6.10.0"
TERMUX_PKG_SRCURL="https://download.qt.io/official_releases/QtForPython/pyside6/PySide6-$TERMUX_PKG_VERSION-src/pyside-setup-everywhere-src-$TERMUX_PKG_VERSION.tar.xz"
TERMUX_PKG_SHA256=f6e18dc880f59fb6c5c37f9f408971d65642dfc7510a15d794b4a3a8e15fcecc
TERMUX_PKG_AUTO_UPDATE=true
# Some packaging code here is based on Arch Linux, other code is original
# https://gitlab.archlinux.org/archlinux/packaging/packages/pyside6/-/blob/8a277986a1fec50c6d8479c5c1afa664d0e20347/PKGBUILD
TERMUX_PKG_DEPENDS="libc++, python, qt6-qtbase, qt6-qtdeclarative, shiboken6"
TERMUX_PKG_RECOMMENDS="qt6-qtcharts, qt6-qtmultimedia, qt6-qtnetworkauth, qt6-qtscxml, qt6-qtsvg, qt6-qttranslations, qt6-qtwebsockets, qt6-shadertools"
# error during configure if libllvm and libllvm-static are not both installed
TERMUX_PKG_BUILD_DEPENDS="libllvm-static, python-numpy, qt6-qtcharts, qt6-qtmultimedia, qt6-qtnetworkauth, qt6-qtscxml, qt6-qtsvg, qt6-qttools, qt6-qtwebsockets, qt6-shadertools"
TERMUX_PKG_PYTHON_COMMON_DEPS="requests"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DCMAKE_SYSTEM_NAME=Linux
-DNUMPY_INCLUDE_DIR=$TERMUX_PREFIX/lib/python$TERMUX_PYTHON_VERSION/site-packages/numpy/_core/include
-DSHIBOKEN_PYTHON_LIBRARIES=-lpython$TERMUX_PYTHON_VERSION
-DCMAKE_CROSSCOMPILING=NO
-DBUILD_TESTS=OFF
-DFORCE_LIMITED_API=OFF
-DNO_QT_TOOLS=yes
"

termux_step_pre_configure() {
	if [[ "$TERMUX_ON_DEVICE_BUILD" == "false" ]]; then
		termux_error_exit "This package is extremely hard to cross-compile. If you know how, please help!"
	fi

	export PYTHONPATH="$TERMUX_PKG_BUILDDIR/sources"
	export CLANG_INSTALL_DIR="$TERMUX_PREFIX"
}

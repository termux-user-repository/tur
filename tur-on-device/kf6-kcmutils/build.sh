TERMUX_PKG_HOMEPAGE="https://community.kde.org/Frameworks"
TERMUX_PKG_DESCRIPTION="Utilities for interacting with KCModules (KDE)"
TERMUX_PKG_LICENSE="LGPL-2.0, LGPL-3.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="6.16.0"
_KF6_MINOR_VERSION="${TERMUX_PKG_VERSION%.*}"
TERMUX_PKG_SRCURL="https://download.kde.org/stable/frameworks/${_KF6_MINOR_VERSION}/kcmutils-${TERMUX_PKG_VERSION}.tar.xz"
TERMUX_PKG_SHA256=403f5eb3288ffbbc64cb6741048007dde82be390da2c50ba147cb474921e3344
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_DEPENDS="libc++, kf6-kconfigwidgets, kf6-kcoreaddons, kf6-kguiaddons, kf6-ki18n, kf6-kitemviews, kf6-kio, kf6-kwidgetsaddons, kf6-kxmlgui, qt6-qtdeclarative, qt6-qtbase"
TERMUX_PKG_BUILD_DEPENDS="extra-cmake-modules (>= ${_KF6_MINOR_VERSION}), qt6-qttools"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DCMAKE_SYSTEM_NAME=Linux
-DKF6_HOST_TOOLING=$TERMUX_PREFIX/opt/kf6/cross/lib/cmake/
-DKDE_INSTALL_QMLDIR=lib/qt6/qml
-DKDE_INSTALL_QTPLUGINDIR=lib/qt6/plugins
-DUSE_DBUS=OFF
"

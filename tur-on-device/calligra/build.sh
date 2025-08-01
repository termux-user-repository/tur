TERMUX_PKG_HOMEPAGE='https://calligra.org/'
TERMUX_PKG_DESCRIPTION='Office and graphic art suite by KDE'
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="25.04.3"
TERMUX_PKG_SRCURL=https://download.kde.org/stable/release-service/${TERMUX_PKG_VERSION}/src/calligra-${TERMUX_PKG_VERSION}.tar.xz
TERMUX_PKG_SHA256=26d75a67eca8a137849bc925da0f65f49f11c29e9fc75346cb2d6627036e6d4f
TERMUX_PKG_DEPENDS="gsl, libc++, libgit2, libetonyek, libodfgen, librevenge, libwpd, libwpg, libwps, libvisio, littlecms, fontconfig, freetype, imath, kf6-karchive, kf6-kcmutils, kf6-kcolorscheme, kf6-kcompletion, kf6-kconfig, kf6-kconfigwidgets, kf6-kcoreaddons, kf6-kcrash, kf6-kdbusaddons, kf6-kguiaddons, kf6-ki18n, kf6-kiconthemes, kf6-kio, kf6-kitemviews, kf6-kjobwidgets, kf6-knotifications, kf6-knotifyconfig, kf6-ktextwidgets, kf6-kwidgetsaddons, kf6-kwindowsystem, kf6-kxmlgui, kf6-purpose, kf6-sonnet, kf6-solid, mediainfo, mlt, opengl, openssl, opentimelineio, perl, poppler, qt6-qtbase, qt6-qtdeclarative, qt6-qtmultimedia, qt6-qtnetworkauth, qt6-qtsvg, qca, qtkeychain, shared-mime-info, zlib"
TERMUX_PKG_BUILD_DEPENDS="boost, eigen, extra-cmake-modules, qt6-qttools, kf6-kconfig-cross-tools"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DCMAKE_SYSTEM_NAME=Linux
-DKF6_HOST_TOOLING=$TERMUX_PREFIX/opt/kf6/cross/lib/cmake/
-DKDE_INSTALL_QMLDIR=lib/qt6/qml
-DKDE_INSTALL_QTPLUGINDIR=lib/qt6/plugins
-DUSE_DBUS=OFF
"

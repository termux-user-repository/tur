TERMUX_PKG_HOMEPAGE=https://libdicom.readthedocs.io
TERMUX_PKG_DESCRIPTION="C library for reading DICOM files"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="1.2.0"
TERMUX_PKG_SRCURL=https://github.com/ImagingDataCommons/libdicom/releases/download/v$TERMUX_PKG_VERSION/libdicom-$TERMUX_PKG_VERSION.tar.xz
TERMUX_PKG_SHA256=3b8c05ceb6bf667fed997f23b476dd32c3dc6380eee1998185c211d86a7b4918
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-Dtests=false
"

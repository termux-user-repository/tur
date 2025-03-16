TERMUX_PKG_HOMEPAGE="https://itstool.org/"
TERMUX_PKG_DESCRIPTION="Translate XML with PO files using W3C Internationalization Tag Set rules"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=2.0.7
TERMUX_PKG_SRCURL=http://files.itstool.org/itstool/itstool-${TERMUX_PKG_VERSION}.tar.bz2
TERMUX_PKG_SHA256=6b9a7cd29a12bb95598f5750e8763cee78836a1a207f85b74d8b3275b27e87ca
TERMUX_PKG_DEPENDS="libxml2-python"

termux_step_pre_configure(){
	cp -r $TERMUX_PKG_SRCDIR/its $TERMUX_PKG_BUILDDIR/its
	autoreconf -vfi
}

termux_step_make(){
	return
}

termux_step_make_install(){
	return
}

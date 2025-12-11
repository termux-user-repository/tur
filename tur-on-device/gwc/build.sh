TERMUX_PKG_HOMEPAGE="https://gwc.sourceforge.net/"
TERMUX_PKG_DESCRIPTION="GTK2 application for cleaning noise in digital music recordings (e.g. digitized vinyl recordings)"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@flosnvjx"
TERMUX_PKG_VERSION="0.22-06r3"
_useCommit="8bbc7cd9f646e8a41cce6eff0bd61d37089e2f76"
TERMUX_PKG_SRCURL="git+https://github.com/AlisterH/gwc.git"
TERMUX_PKG_GIT_BRANCH="stable"
TERMUX_PKG_SHA256=SKIP_CHECKSUM
TERMUX_PKG_DEPENDS="fftw,libsndfile,gtk2,alsa-lib"
TERMUX_PKG_SUGGESTS="alsa-plugins"
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_post_get_source() {
	git fetch --unshallow
	git checkout "$_useCommit"
}

termux_step_pre_configure() {
	autoreconf -fi
	sed -ie '/^CFLAGS = /s%$% -std=gnu17 -Wno-error=implicit-function-declaration -Wno-implicit-function-declaration -Wno-int-conversion -Wno-incompatible-pointer-types %' ?akefile* meschach/?akefile*

	## avoid to treat this as an autoconf script
	mv meschach/configur{e,.}
}

termux_step_make() {
	mv meschach/configur{.,e}
	make -j1
}

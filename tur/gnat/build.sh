TERMUX_PKG_HOMEPAGE=https://github.com/termux-user-repository/tur
TERMUX_PKG_DESCRIPTION="GNU Ada Compiler"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=11
TERMUX_PKG_SKIP_SRC_EXTRACT=true
TERMUX_PKG_DEPENDS="gcc-11"
TERMUX_PKG_PLATFORM_INDEPENDENT=true

termux_step_make_install() {
	TERMUX_PKG_DEPENDS+=", gcc-default-11"
	local _bin _bn
	for _bin in $TERMUX_PREFIX/bin/gnat*-11; do
		_bn=$(basename $_bin)
		ln -sfrv $_bin $TERMUX_PREFIX/bin/${_bn%-11}
	done

	mkdir -p $TERMUX_PREFIX/share/$TERMUX_PKG_NAME
	touch -f $TERMUX_PREFIX/share/.placeholder
	cp -f $TERMUX_PKG_BUILDER_DIR/LICENSE $TERMUX_PKG_SRCDIR
}

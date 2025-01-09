TERMUX_PKG_HOMEPAGE=https://github.com/dosemu2/install-freedos
TERMUX_PKG_DESCRIPTION="FreeDOS installed for dosemu2"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@stsp"
TERMUX_PKG_VERSION=0.3
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=https://github.com/dosemu2/install-freedos/archive/refs/tags/${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=aeade1ec86902df35e0926f802319b625de8fafac33fe834a286b3fe971a086f
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_DEPENDS="python"
TERMUX_PKG_PYTHON_TARGET_DEPS="tqdm"

termux_step_make_install() {
	make -C $TERMUX_PKG_SRCDIR install
}

termux_step_create_debscripts() {
	cat <<- EOF > ./postinst
	#!$TERMUX_PREFIX/bin/sh
	echo "Installing dependencies through pip. This may take a while..."
	pip3 install ${TERMUX_PKG_PYTHON_TARGET_DEPS//, / }
	EOF
	chmod +x ./postinst
}

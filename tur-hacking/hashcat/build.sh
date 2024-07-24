TERMUX_PKG_HOMEPAGE=https://hashcat.net/hashcat/
TERMUX_PKG_DESCRIPTION="World's fastest and most advanced password recovery utility"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_LICENSE_FILE="docs/license.txt"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="6.2.6"
TERMUX_PKG_REVISION=5
TERMUX_PKG_SRCURL=https://github.com/hashcat/hashcat/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=b25e1077bcf34908cc8f18c1a69a2ec98b047b2cbcf0f51144dcf3ba1e0b7b2a
TERMUX_PKG_DEPENDS="opencl-vendor-driver, libiconv"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_configure() {
	if [ "$TERMUX_ARCH" = 'aarch64' ]; then
		CFLAGS+=' -march=armv8.1-a+crypto'
		CXXFLAGS+=' -march=armv8.1-a+crypto'
	fi
}

termux_step_make() {
	rm -rf $TERMUX_PREFIX/opt/hashcat/
	mkdir -p $TERMUX_PREFIX/opt/hashcat/

	make -j $TERMUX_PKG_MAKE_PROCESSES
}

termux_step_make_install() {
	make install

	cat <<- EOF > "$TERMUX_PREFIX"/bin/hashcat
	LD_LIBRARY_PATH="$TERMUX_PREFIX/opt/vendor/lib:$TERMUX_PREFIX/lib" $TERMUX_PREFIX/opt/hashcat/bin/hashcat "\$@"
	EOF
	chmod 700 "$TERMUX_PREFIX"/bin/hashcat
}

termux_step_create_debscripts() {
	cat <<- EOF > ./postinst
		#!${TERMUX_PREFIX}/bin/sh
		mkdir -p "\$HOME/.local/share/hashcat/"
	EOF
}

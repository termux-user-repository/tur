TERMUX_PKG_HOMEPAGE=https://hashcat.net/hashcat/
TERMUX_PKG_DESCRIPTION="World's fastest and most advanced password recovery utility"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_LICENSE_FILE="docs/license.txt"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="7.1.2"
TERMUX_PKG_SRCURL=https://github.com/hashcat/hashcat/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=9546a6326d747530b44fcc079babad40304a87f32d3c9080016d58b39cfc8b96
TERMUX_PKG_DEPENDS="libc++, libiconv, opencl-vendor-driver"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_configure() {
	LDFLAGS+=" -liconv"
}

termux_step_make() {
	rm -rf $TERMUX_PREFIX/opt/hashcat/
	mkdir -p $TERMUX_PREFIX/opt/hashcat/

	make \
		CC_LINUX="$CC" \
		CXX_LINUX="$CXX" \
		AR_LINUX="$AR" \
		-j $TERMUX_PKG_MAKE_PROCESSES \
		host_linux modules_linux
}

termux_step_make_install() {
	make \
		CC_LINUX="$CC" \
		CXX_LINUX="$CXX" \
		AR_LINUX="$AR" \
		install_docs install_shared install_tools install_tunings install_kernels install_modules install_hashcat

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

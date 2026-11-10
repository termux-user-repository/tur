TERMUX_PKG_HOMEPAGE=https://hashcat.net/hashcat/
TERMUX_PKG_DESCRIPTION="World's fastest and most advanced password recovery utility"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_LICENSE_FILE="docs/license.txt"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="8.0.0"
TERMUX_PKG_SRCURL=https://github.com/hashcat/hashcat/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=6281721ef2bc57aed1ffa1a186aa39d01cee09899741cb58e027733a373c2ae3
TERMUX_PKG_DEPENDS="libandroid-glob, libandroid-spawn, libiconv, liblzma, opencl-vendor-driver, zlib, zstd"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	CFLAGS+=" $CPPFLAGS"
	LDFLAGS+=" -landroid-glob -landroid-spawn -liconv"
}

termux_step_make() {
	make \
		CC="$CC" \
		CC_NATIVE="$CC" \
		AR_NATIVE="$AR" \
		UNAME=Android \
		PREFIX="$TERMUX_PREFIX/opt/hashcat" \
		LFLAGS="$LDFLAGS" \
		SHARED=1 \
		RUST_SKIP_REASON="disabled" \
		-j $TERMUX_PKG_MAKE_PROCESSES \
		hashcat modules bridges feeds
}

termux_step_make_install() {
	make \
		CC="$CC" \
		CC_NATIVE="$CC" \
		AR_NATIVE="$AR" \
		UNAME=Android \
		PREFIX="$TERMUX_PREFIX/opt/hashcat" \
		LFLAGS="$LDFLAGS" \
		SHARED=1 \
		RUST_SKIP_REASON="disabled" \
		install_docs \
		install_shared \
		install_tools \
		install_library \
		install_tunings \
		install_pcfg \
		install_rules \
		install_kernels \
		install_modules \
		install_bridges \
		install_python \
		install_feeds \
		install_hashcat

	cat <<- EOF > "$TERMUX_PREFIX"/bin/hashcat
	#!$TERMUX_PREFIX/bin/sh
	export LD_LIBRARY_PATH="$TERMUX_PREFIX/opt/vendor/lib:$TERMUX_PREFIX/opt/hashcat/lib:$TERMUX_PREFIX/lib:\$LD_LIBRARY_PATH"
	exec $TERMUX_PREFIX/opt/hashcat/bin/hashcat "\$@"
	EOF
	chmod 755 "$TERMUX_PREFIX"/bin/hashcat
}

termux_step_create_debscripts() {
	cat <<- EOF > ./postinst
		#!${TERMUX_PREFIX}/bin/sh
		mkdir -p "\$HOME/.local/share/hashcat/"
	EOF
}

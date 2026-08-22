TERMUX_PKG_HOMEPAGE=https://github.com/Raku/nqp
TERMUX_PKG_DESCRIPTION="Lightweight Raku-like environment for virtual machines"
TERMUX_PKG_LICENSE="Artistic-License-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="2026.08"
TERMUX_PKG_SRCURL=https://github.com/Raku/nqp/releases/download/$TERMUX_PKG_VERSION/nqp-$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=120de1ac6f3246e7c5d04261ef18e64d9c3663f6670e952528d0d5c04b889cf2
TERMUX_PKG_DEPENDS="moarvm"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--prefix=$TERMUX_PREFIX
--backends=moar
"

termux_step_pre_configure() {
	if [ "${TERMUX_ON_DEVICE_BUILD}" = false ]; then
		termux_error_exit "This package doesn't support cross-compiling."
	fi
}

termux_step_configure() {
	# Symlink arm compiler
	if [ "$TERMUX_ARCH" = "arm" ]; then
		mkdir -p $TERMUX_PKG_TMPDIR/_fake_bin
		cat <<- EOF > $TERMUX_PKG_TMPDIR/_fake_bin/armv7a-linux-androideabi-gcc
		#!$TERMUX_PREFIX/bin/sh
		exec $CC "\$@"
		EOF
		chmod +x $TERMUX_PKG_TMPDIR/_fake_bin/armv7a-linux-androideabi-gcc
		export PATH="$TERMUX_PKG_TMPDIR/_fake_bin:$PATH"
	fi

	perl Configure.pl $TERMUX_PKG_EXTRA_CONFIGURE_ARGS
}

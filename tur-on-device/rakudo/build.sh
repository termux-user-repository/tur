TERMUX_PKG_HOMEPAGE=https://rakudo.org
TERMUX_PKG_DESCRIPTION="Mature, production-ready implementation of the Raku language"
TERMUX_PKG_LICENSE="Artistic-License-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="2026.02"
TERMUX_PKG_SRCURL=https://github.com/rakudo/rakudo/releases/download/$TERMUX_PKG_VERSION/rakudo-$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=1d9cc55427dfdf39ef088c0f22649f341d11e34b966ef2fa28280c8d94052bf7
TERMUX_PKG_DEPENDS="libc++, moarvm, nqp"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--prefix=$TERMUX_PREFIX
--rakudo-home=$TERMUX_PREFIX/raku
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

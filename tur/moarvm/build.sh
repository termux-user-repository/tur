TERMUX_PKG_HOMEPAGE=https://moarvm.org/
TERMUX_PKG_DESCRIPTION="Virtual machine for Rakudo Perl 6 and NQP"
TERMUX_PKG_LICENSE="Artistic-License-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="2026.05"
TERMUX_PKG_SRCURL=https://github.com/MoarVM/MoarVM/releases/download/$TERMUX_PKG_VERSION/MoarVM-$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=aa6d39debc9154fb353c94debb78690a52e61de0745f744d7f2f7144451e7295
TERMUX_PKG_DEPENDS="libc++, libffi, libuv, zstd"
TERMUX_PKG_BUILD_IN_SRC=true

moarvm_host="$TERMUX_HOST_PLATFORM"
if [ "$TERMUX_ARCH" = "arm" ]; then
	moarvm_host="armv7a-linux-androideabi"
fi

TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--build=$TERMUX_BUILD_TUPLE
--host=$moarvm_host
--prefix=$TERMUX_PREFIX
--c11-atomics
--has-libffi
--has-libuv
--no-jit
"

termux_step_configure() {
	TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" --ar=$AR"

	perl Configure.pl $TERMUX_PKG_EXTRA_CONFIGURE_ARGS
}

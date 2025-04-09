TERMUX_PKG_HOMEPAGE=https://moarvm.org/
TERMUX_PKG_DESCRIPTION="Virtual machine for Rakudo Perl 6 and NQP"
TERMUX_PKG_LICENSE="Artistic-License-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="2025.03"
TERMUX_PKG_SRCURL=https://github.com/MoarVM/MoarVM/releases/download/$TERMUX_PKG_VERSION/MoarVM-$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=2ee8a0ab3f1164e4406bf41169de7ceb8e177b8d86acfeb3736f70704578f933
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

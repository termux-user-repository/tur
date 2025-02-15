TERMUX_PKG_HOMEPAGE=https://dpp.dev
TERMUX_PKG_DESCRIPTION="D++ is a lightweight and simple library for Discord written in modern C++."
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@OrdinaryEnder"
TERMUX_PKG_VERSION="10.1.0"
TERMUX_PKG_SRCURL=https://github.com/brainboxdotcc/dpp/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_DEPENDS="libc++, libopus, libsodium, openssl, zlib"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_SHA256=c794053b926c019e8f4771523362ecfdf3038a7899bad4400c163bd1e13584e3

TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DRUN_LDCONFIG=OFF
-DAVX_TYPE=T_fallback
"

termux_step_pre_configure() {
	termux_setup_cmake

	# Use a dummy include for `sys/ucontext.h` to get rid of `struct user`
	mkdir -p $TERMUX_PKG_TMPDIR/dummy-include/sys/
	echo "" > $TERMUX_PKG_TMPDIR/dummy-include/sys/ucontext.h
	CPPFLAGS+=" -I$TERMUX_PKG_TMPDIR/dummy-include"
}

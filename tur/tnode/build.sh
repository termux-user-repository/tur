TERMUX_PKG_HOMEPAGE="https://github.com/Irithell/tnode"
TERMUX_PKG_DESCRIPTION="POSIX compatibility shim for Android SDCARD filesystem — LD_PRELOAD bridge for Node.js, Python, Ruby, C and C++ runtimes in Termux"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@Irithell"
TERMUX_PKG_VERSION="0.1.3"
TERMUX_PKG_SRCURL="https://github.com/Irithell/tnode/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=f81b959bab01c818c8830994df1bdfaee1f4dd96ed5e198a46e9b5431418777d
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true

case "$TERMUX_ARCH" in
	aarch64) CARGO_TARGET="aarch64-linux-android"    ;;
	x86_64)  CARGO_TARGET="x86_64-linux-android"     ;;
	arm)     CARGO_TARGET="armv7-linux-androideabi"  ;;
	i686)    CARGO_TARGET="i686-linux-android"       ;;
	*)       termux_error_exit "unsupported architecture: $TERMUX_ARCH" ;;
esac

termux_step_pre_configure() {
	termux_setup_rust
}

termux_step_configure() {
	:
}

termux_step_make() {
	local env_target=$(echo "$CARGO_TARGET" | tr '[:lower:]-' '[:upper:]_')
	export CARGO_TARGET_${env_target}_LINKER="$CC"
	export CARGO_TARGET_${env_target}_AR="$AR"
	
	export CFLAGS="$CFLAGS"
	export LDFLAGS="$LDFLAGS"

	cargo build \
		--target "$CARGO_TARGET" \
		--release \
		--locked
}

termux_step_make_install() {
	install -Dm755 "target/${CARGO_TARGET}/release/tnode" \
		"${TERMUX_PREFIX}/bin/tnode"

	install -Dm644 "target/${CARGO_TARGET}/release/libthook.so" \
		"${TERMUX_PREFIX}/lib/libthook.so"
}

TERMUX_PKG_HOMEPAGE=https://github.com/Orange-OpenSource/hurl
TERMUX_PKG_DESCRIPTION="Hurl, run and test HTTP requests with plain text"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@SunPodder"
TERMUX_PKG_VERSION="7.0.0"
TERMUX_PKG_SRCURL="https://github.com/Orange-OpenSource/hurl/archive/refs/tags/${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=3f505848aabd9eec78360928b0fcbfea237a049b5c8d25b8d9e0aeb3f9d8dfed
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_BUILD_DEPENDS="openssl, libxml2"

termux_step_make() {
	termux_setup_rust

	BINDGEN_EXTRA_CLANG_ARGS="--target=$CCTERMUX_HOST_PLATFORM"
	BINDGEN_EXTRA_CLANG_ARGS+=" --sysroot=$NDK/toolchains/llvm/prebuilt/linux-x86_64/sysroot"
	local env_name=BINDGEN_EXTRA_CLANG_ARGS_${CARGO_TARGET_NAME}
	env_name=${env_name//-/_}
	export "$env_name"="$BINDGEN_EXTRA_CLANG_ARGS"

	cargo build --jobs $TERMUX_PKG_MAKE_PROCESSES --target $CARGO_TARGET_NAME --release
}

termux_step_make_install() {
	install -Dm755 -t $TERMUX_PREFIX/bin target/${CARGO_TARGET_NAME}/release/hurl
	install -Dm755 -t $TERMUX_PREFIX/bin target/${CARGO_TARGET_NAME}/release/hurlfmt
}

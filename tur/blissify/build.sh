TERMUX_PKG_HOMEPAGE="https://github.com/Polochon-street/blissify-rs"
TERMUX_PKG_DESCRIPTION="A MPD helper utility for generating smart playlist"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@flosnvjx"
TERMUX_PKG_VERSION="0.6.1"
_COMMIT=74d532d9e85d14dbb18ab6653edbdf05ef5fbbe7
TERMUX_PKG_DEPENDS="ffmpeg,libsqlite"
TERMUX_PKG_SRCURL="git+https://github.com/Polochon-street/blissify-rs"
TERMUX_PKG_GIT_BRANCH=master
TERMUX_PKG_SHA256=SKIP_CHECKSUM
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_post_get_source() {
	git fetch --unshallow
	git checkout $_COMMIT

	local version="$(awk '/^\[[^\]]+]$/{gsub(/\[|]/,"");sect=$0}sect=="package"&&/^version = "[0-9.]+"/' Cargo.toml | sed -Ee 's@^version = "([0-9.]+)"$@\1@')"

	if [ "$TERMUX_PKG_VERSION" != "$version" ]; then
		termux_error_exit "TERMUX_PKG_VERSION diffrent from actual crate version ($TERMUX_PKG_VERSION != $version)"
	fi
}

termux_step_pre_configure() {
	termux_setup_rust

	## fix error: function-like macro '__GLIBC_USE' is not defined
	export BINDGEN_EXTRA_CLANG_ARGS_${CARGO_TARGET_NAME//-/_}="--sysroot ${TERMUX_STANDALONE_TOOLCHAIN}/sysroot --target=${CARGO_TARGET_NAME}"
	## fix error: unrecognized command-line option '-mfpu=neon'
	unset CFLAGS
}

termux_step_make() {
	cargo build --jobs $TERMUX_PKG_MAKE_PROCESSES --target $CARGO_TARGET_NAME --release --locked --features=default,bliss-audio/update-aubio-bindings
}

termux_step_make_install() {
	install -vDm700 -t $TERMUX_PREFIX/bin target/${CARGO_TARGET_NAME}/release/blissify
	install -vDm600 -t $TERMUX_PREFIX/share/doc/blissify README* CHANGELOG*
}

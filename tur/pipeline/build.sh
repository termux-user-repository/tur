TERMUX_PKG_HOMEPAGE="https://gitlab.com/schmiddi-on-mobile/pipeline"
TERMUX_PKG_DESCRIPTION="A YouTube frontend for mobile Linux"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="4.0.2"
TERMUX_PKG_SRCURL="https://gitlab.com/schmiddi-on-mobile/pipeline/-/archive/${TERMUX_PKG_VERSION}/pipeline-${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256="392eaed21806ecd80fd2e4553ad086746159f3b83c485de30c2e037062cf3532"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_DEPENDS="glib, gtk4, clapper, clapper-enhancers, sqlite, openssl, ca-certificates, python-yt-dlp, ffmpeg"
TERMUX_PKG_BUILD_DEPENDS="rust, glib-cross, g-ir-scanner, blueprint-compiler"

termux_step_pre_configure() {
	termux_setup_rust
	termux_setup_gir
	termux_setup_bpc
	termux_setup_glib_cross_pkg_config_wrapper

	export PATH="${TERMUX_PREFIX}/opt/glib/cross/bin:$PATH"

	export CARGO_BUILD_TARGET="${CARGO_TARGET_NAME}"
	export BINDGEN_EXTRA_CLANG_ARGS_${CARGO_TARGET_NAME//-/_}="--sysroot ${TERMUX_STANDALONE_TOOLCHAIN}/sysroot --target=${CARGO_TARGET_NAME}"

	local target_var="CARGO_TARGET_${CARGO_TARGET_NAME//-/_}_RUSTFLAGS"
	target_var=${target_var^^}
	export ${target_var}="${!target_var:-} -C link-arg=-liconv"
}

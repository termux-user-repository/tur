TERMUX_PKG_HOMEPAGE=https://tabby.tabbyml.com/
TERMUX_PKG_DESCRIPTION="Self-hosted AI coding assistant"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="0.24.0"
TERMUX_PKG_SRCURL=git+https://github.com/TabbyML/tabby
TERMUX_PKG_DEPENDS="graphviz, libopenblas, libsqlite"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_TAG_TYPE="latest-release-tag"
# simd-json v0.13.10 fail to compile for i686 with error related to avx2 instructions
# ARM_NEON is not supported by arm, therefore llama.cpp/ggml uses undeclared identifier 'vld1q_f16'
TERMUX_PKG_BLACKLISTED_ARCHES="arm, i686"

termux_step_pre_configure() {
	termux_setup_rust
	termux_setup_cmake

	# Dummy CMake toolchain file to workaround build error:
	# CMake Error at /home/builder/.termux-build/_cache/cmake-3.30.3/share/cmake-3.30/Modules/Platform/Android-Determine.cmake:218 (message):
	# Android: Neither the NDK or a standalone toolchain was found.
	export TARGET_CMAKE_TOOLCHAIN_FILE="${TERMUX_PKG_BUILDDIR}/android.toolchain.cmake"
	touch "${TERMUX_PKG_BUILDDIR}/android.toolchain.cmake"

	if [ "$TERMUX_ARCH" = "x86_64" ]; then
		local env_host=$(printf $CARGO_TARGET_NAME | tr a-z A-Z | sed s/-/_/g)
		export CARGO_TARGET_${env_host}_RUSTFLAGS+=" -C link-arg=$($CC -print-libgcc-file-name)"
	fi

	LDFLAGS+=" -fopenmp -static-openmp"
}

termux_step_make() {
	cargo build --jobs $TERMUX_PKG_MAKE_PROCESSES --target $CARGO_TARGET_NAME --release
}

termux_step_make_install() {
	install -Dm700 target/${CARGO_TARGET_NAME}/release/tabby $TERMUX_PREFIX/bin/
	install -Dm700 target/${CARGO_TARGET_NAME}/release/llama-server $TERMUX_PREFIX/bin/
}

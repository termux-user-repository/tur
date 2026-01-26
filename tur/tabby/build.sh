TERMUX_PKG_HOMEPAGE=https://tabby.tabbyml.com/
TERMUX_PKG_DESCRIPTION="Self-hosted AI coding assistant"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="0.32.0"
TERMUX_PKG_SRCURL=git+https://github.com/TabbyML/tabby
TERMUX_PKG_DEPENDS="graphviz, libc++, libopenblas, libsqlite"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_TAG_TYPE="latest-release-tag"
# simd-json v0.13.10 fail to compile for i686 with error related to avx2 instructions
# ARM_NEON is not supported by arm, therefore llama.cpp/ggml uses undeclared identifier 'vld1q_f16'
TERMUX_PKG_EXCLUDED_ARCHES="arm, i686"

termux_step_pre_configure() {
	termux_setup_rust
	termux_setup_cmake

	export TARGET_CMAKE_TOOLCHAIN_FILE="$TERMUX_PKG_TMPDIR/android.toolchain.cmake"
	cat <<- EOL > "$TARGET_CMAKE_TOOLCHAIN_FILE"
	set(CMAKE_ASM_FLAGS "\${CMAKE_ASM_FLAGS} --target=${CCTERMUX_HOST_PLATFORM}")
	set(CMAKE_C_FLAGS "\${CMAKE_C_FLAGS} --target=${CCTERMUX_HOST_PLATFORM} ${CFLAGS}")
	set(CMAKE_CXX_FLAGS "\${CMAKE_CXX_FLAGS} --target=${CCTERMUX_HOST_PLATFORM} ${CXXFLAGS}")
	set(CMAKE_C_COMPILER "${TERMUX_STANDALONE_TOOLCHAIN}/bin/${CC}")
	set(CMAKE_CXX_COMPILER "${TERMUX_STANDALONE_TOOLCHAIN}/bin/${CXX}")
	set(CMAKE_AR "$(command -v ${AR})")
	set(CMAKE_RANLIB "$(command -v ${RANLIB})")
	set(CMAKE_STRIP "$(command -v ${STRIP})")
	set(CMAKE_FIND_ROOT_PATH "${TERMUX_PREFIX}")
	set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM "NEVER")
	set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE "ONLY")
	set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY "ONLY")
	set(CMAKE_SKIP_INSTALL_RPATH "ON")
	set(CMAKE_USE_SYSTEM_LIBRARIES "True")
	set(CMAKE_CROSSCOMPILING "True")
	set(CMAKE_LINKER "${TERMUX_STANDALONE_TOOLCHAIN}/bin/${LD} ${LDFLAGS}")
	set(CMAKE_SYSTEM_NAME "Android")
	set(CMAKE_SYSTEM_VERSION "${TERMUX_PKG_API_LEVEL}")
	set(CMAKE_SYSTEM_PROCESSOR "${TERMUX_ARCH}")
	set(CMAKE_ANDROID_STANDALONE_TOOLCHAIN "${TERMUX_STANDALONE_TOOLCHAIN}")
	EOL

	if [ "$TERMUX_ARCH" = "x86_64" ]; then
		local env_host=$(printf $CARGO_TARGET_NAME | tr a-z A-Z | sed s/-/_/g)
		export CARGO_TARGET_${env_host}_RUSTFLAGS+=" -C link-arg=$($CC -print-libgcc-file-name)"
	fi
}

termux_step_make() {
	cargo build --jobs $TERMUX_PKG_MAKE_PROCESSES --target $CARGO_TARGET_NAME --release
}

termux_step_make_install() {
	mkdir -p $TERMUX_PREFIX/opt/tabby/bin/
	install -Dm700 target/${CARGO_TARGET_NAME}/release/tabby $TERMUX_PREFIX/opt/tabby/bin/
	install -Dm700 target/${CARGO_TARGET_NAME}/release/llama-server $TERMUX_PREFIX/opt/tabby/bin/

	# Create start script
	cat << EOF > $TERMUX_PREFIX/bin/tabby
#!$TERMUX_PREFIX/bin/env sh

exec $TERMUX_PREFIX/opt/tabby/bin/tabby "\$@"

EOF
	chmod +x $TERMUX_PREFIX/bin/tabby
}

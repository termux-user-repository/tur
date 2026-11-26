TERMUX_PKG_HOMEPAGE="https://github.com/VibeDarling"
TERMUX_PKG_DESCRIPTION="Darwin/macOS emulation layer for Linux"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@IntinteDAO"
TERMUX_PKG_VERSION="0.1.20260906-15"
TERMUX_PKG_SRCURL="https://github.com/VibeDarling/darling/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=232ea4695c6ac5bc92c51073c294f031b565b028660c9d94dc2c4a714f36dbcc
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_EXCLUDED_ARCHES="arm, i686"
TERMUX_PKG_DEPENDS="dbus, libandroid-posix-semaphore, libbsd, libc++, libcap, libelf, libicu, liblzma, libucontext, libxml2, openssl, python, xdg-user-dirs, zlib"
TERMUX_PKG_BUILD_DEPENDS="bison, flex"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
	-DCOMPONENTS=cli
	-DENABLE_METAL=OFF
	-DENABLE_TESTS=OFF
	-DCMAKE_ASM-ATT_COMPILER=clang
"

termux_step_pre_configure() {
	local CLANG=$(command -v clang-18 || command -v clang || true)
	local CLANGXX=$(command -v clang++-18 || command -v clang++ || true)
	if [ -n "$CLANG" ]; then
		export CC_FOR_BUILD="$CLANG"
	fi
	if [ -n "$CLANGXX" ]; then
		export CXX_FOR_BUILD="$CLANGXX"
	fi

	if [ "$TERMUX_ARCH" = "aarch64" ]; then
		TERMUX_PKG_EXTRA_CONFIGURE_ARGS+="
			-DTARGET_ARM64=ON
			-DTARGET_i386=OFF
			-DTARGET_x86_64=OFF
		"
		export CFLAGS="-fstack-protector-strong -Oz -mbranch-protection=none -D__arm64__"
		export CXXFLAGS="-fstack-protector-strong -Oz -mbranch-protection=none -D__arm64__"
	elif [ "$TERMUX_ARCH" = "x86_64" ]; then
		TERMUX_PKG_EXTRA_CONFIGURE_ARGS+="
			-DTARGET_ARM64=OFF
			-DTARGET_i386=OFF
			-DTARGET_x86_64=ON
		"
		export CFLAGS="-fstack-protector-strong -Oz"
		export CXXFLAGS="-fstack-protector-strong -Oz"
	fi

	export CPPFLAGS=""
	export LDFLAGS=""
}

termux_step_make_install() {
	DESTDIR="$TERMUX_PKG_MASSAGEDIR" ninja install

	# Ensure standard Darwin symlinks and tmp directory are present
	local LIBEXEC_DIR="$TERMUX_PKG_MASSAGEDIR/$TERMUX_PREFIX/libexec/darling"
	if [ -d "$LIBEXEC_DIR" ]; then
		mkdir -p "$LIBEXEC_DIR/private"
		rm -rf "$LIBEXEC_DIR/private/tmp"
		ln -sf ../Volumes/SystemRoot$TERMUX_PREFIX/tmp "$LIBEXEC_DIR/private/tmp"
	fi
}

termux_step_post_get_source() {
	git init
	git remote add origin https://github.com/VibeDarling/darling.git
	git fetch --depth 1 origin tag "v${TERMUX_PKG_VERSION}"
	git reset --hard FETCH_HEAD
	if ! git submodule update --init --recursive --depth 1; then
		git submodule update --init --recursive
	fi
}

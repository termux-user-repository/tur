TERMUX_PKG_HOMEPAGE=https://www.chromium.org/Home
TERMUX_PKG_DESCRIPTION="Chromium web browser"
TERMUX_PKG_LICENSE="BSD 3-Clause"
TERMUX_PKG_MAINTAINER="@licy183"
_CHROMIUM_VERSION=107.0.5304.107
TERMUX_PKG_VERSION=$_CHROMIUM_VERSION
# TERMUX_PKG_SRCURL=(https://commondatastorage.googleapis.com/chromium-browser-official/chromium-$_CHROMIUM_VERSION.tar) # DEBUG ONLY
TERMUX_PKG_SRCURL=(https://commondatastorage.googleapis.com/chromium-browser-official/chromium-$_CHROMIUM_VERSION.tar.xz)
# TERMUX_PKG_SHA256=(4ab808502269e9ce8da5bb3628e6ffd39f64c0cb2451c0d213962a98b71095f5) # DEBUG ONLY
TERMUX_PKG_SHA256=(49d96b1247690b5ecc061d91fdb203eaef38c6d6e1bb60ca4472eaa99bba1a3e)
TERMUX_PKG_DEPENDS="fontconfig, freetype, harfbuzz, libdav1d, libdrm, libxkbcommon, libminizip, libnss, libwayland, libjpeg-turbo, libpng, mesa, openssl, zlib"
TERMUX_PKG_BUILD_DEPENDS="vulkan-headers, vulkan-loader-android"
TERMUX_PKG_BUILD_IN_SRC=true

SYSTEM_LIBRARIES="
dav1d
libdrm
libjpeg
libpng
fontconfig
freetype
harfbuzz-ng
zlib
"

# TODO:
# (1) Enable SSL (Possibly reuse the SSL Provider of fuchsia or use nss)
# (2) Set google keys
# (3) Enable GUI (non-headless)
# (4) Use system libraries when possible

termux_step_post_get_source() {
	local _lib
	for _lib in $SYSTEM_LIBRARIES libjpeg_turbo; do
		echo "Removing buildscripts for system provided $_lib"
		find . -type f -path "*third_party/$_lib/*" \
			\! -path "*third_party/$_lib/chromium/*" \
			\! -path "*third_party/$_lib/google/*" \
			\! -path './base/third_party/icu/*' \
			\! -path './third_party/libxml/*' \
			\! -path './third_party/pdfium/third_party/freetype/include/pstables.h' \
			\! -path './third_party/harfbuzz-ng/utils/hb_scoped.h' \
			\! -path './third_party/crashpad/crashpad/third_party/zlib/zlib_crashpad.h' \
			\! -regex '.*\.\(gn\|gni\|isolate\|py\)' \
			-delete
	done

	python3 build/linux/unbundle/replace_gn_files.py --system-libraries \
		$SYSTEM_LIBRARIES
	python3 third_party/libaddressinput/chromium/tools/update-strings.py
}

termux_step_configure() {
	termux_setup_gn
	termux_setup_ninja
	termux_setup_nodejs

	# Link to system tools required by the build
	mkdir -p third_party/node/linux/node-linux-x64/bin
	ln -sf $(command -v node) third_party/node/linux/node-linux-x64/bin/
	ln -sf $(command -v java) third_party/jdk/current/bin/

	_NUMMY_FILES=()

	# Dummy librt.so if needed
	# Why not dummy a librt.a? Some of the binaries reference symbols in `android/log.h`
	# for some reason, such as the `chrome_crashpad_handler`, which needs to link with 
	# libprotobuf_lite.a, but it is hard to remove the usage of `android/log.h` in protobuf. 
	if [ ! -f "$TERMUX_PREFIX/lib/librt.so" ]; then
		echo "INPUT(-llog)" > "$TERMUX_PREFIX/lib/librt.so"
		_NUMMY_FILES+=("$TERMUX_PREFIX/lib/librt.so")
	fi

	# Dummy libpthread.a if needed
	if [ ! -f "$TERMUX_PREFIX/lib/libpthread.a" ]; then
		echo '!<arch>' > "$TERMUX_PREFIX/lib/libpthread.a"
		_NUMMY_FILES+=("$TERMUX_PREFIX/lib/libpthread.a")
	fi

	# Dummy libresolv.a if needed
	if [ ! -f "$TERMUX_PREFIX/lib/libresolv.a" ]; then
		echo '!<arch>' > "$TERMUX_PREFIX/lib/libresolv.a"
		_NUMMY_FILES+=("$TERMUX_PREFIX/lib/libresolv.a")
	fi

	# Merge sysroots
	mkdir -p $TERMUX_PKG_TMPDIR/sysroot
	pushd $TERMUX_PKG_TMPDIR/sysroot
	mkdir -p usr/include usr/lib
	cp -R $TERMUX_STANDALONE_TOOLCHAIN/sysroot/usr/include/* usr/include
	cp -R $TERMUX_STANDALONE_TOOLCHAIN/sysroot/usr/include/$TERMUX_HOST_PLATFORM/* usr/include
	cp -R $TERMUX_STANDALONE_TOOLCHAIN/sysroot/usr/lib/$TERMUX_HOST_PLATFORM/$TERMUX_PKG_API_LEVEL/* usr/lib/
	cp "$TERMUX_STANDALONE_TOOLCHAIN/sysroot/usr/lib/$TERMUX_HOST_PLATFORM/libc++_shared.so" usr/lib/
	cp "$TERMUX_STANDALONE_TOOLCHAIN/sysroot/usr/lib/$TERMUX_HOST_PLATFORM/libc++_static.a" usr/lib/
	cp "$TERMUX_STANDALONE_TOOLCHAIN/sysroot/usr/lib/$TERMUX_HOST_PLATFORM/libc++abi.a" usr/lib/
	cp -Rf $TERMUX_PREFIX/include/* usr/include
	cp -Rf $TERMUX_PREFIX/lib/* usr/lib
	# WTF: This symlink is needed for building skia. But why?
	rm -f ./data
	ln -sf /data ./data
	popd

	rm -rf out/Headless
	mkdir -p out/Headless
	echo "
import(\"//build/args/headless.gn\")
target_cpu = \"arm64\"
target_rpath = \"$TERMUX_PREFIX/lib\"
target_sysroot = \"$TERMUX_PKG_TMPDIR/sysroot\"
use_sysroot=false
is_debug = false
clang_base_path = \"$TERMUX_STANDALONE_TOOLCHAIN\"
clang_use_chrome_plugins = false
dcheck_always_on = false
is_official_build = true
use_qt = false
use_dbus = false
chrome_pgo_phase = 0
treat_warnings_as_errors = false
use_system_freetype = true
use_system_harfbuzz = true
use_system_libdrm = true
use_system_libjpeg = true
use_system_libpng = true
use_system_zlib = true
use_custom_libcxx = false
use_allocator_shim = false
use_allocator = \"none\"
use_nss_certs = false
is_official_build = false
" >> out/Headless/args.gn

	gn gen out/Headless --export-compile-commands
}

termux_step_make() {
	ninja -C out/Headless headless_shell
	$STRIP out/Headless/headless_shell
	mv out/Headless/headless_shell $TERMUX_PREFIX/bin
	chmod +x $TERMUX_PREFIX/bin/headless_shell
}

TERMUX_PKG_HOMEPAGE=https://www.chromium.org/Home
TERMUX_PKG_DESCRIPTION="Chromium web browser (Headless Shell)"
TERMUX_PKG_LICENSE="BSD 3-Clause"
TERMUX_PKG_MAINTAINER="@licy183"
_CHROMIUM_VERSION=107.0.5304.107
TERMUX_PKG_VERSION=$_CHROMIUM_VERSION
TERMUX_PKG_SRCURL=(https://commondatastorage.googleapis.com/chromium-browser-official/chromium-$_CHROMIUM_VERSION.tar.xz)
TERMUX_PKG_SHA256=(49d96b1247690b5ecc061d91fdb203eaef38c6d6e1bb60ca4472eaa99bba1a3e)
TERMUX_PKG_DEPENDS="fontconfig, freetype, harfbuzz, libdav1d, libdrm, libxkbcommon, libminizip, libnss, libwayland, libjpeg-turbo, libpng, mesa, openssl, zlib"
TERMUX_PKG_BUILD_DEPENDS="vulkan-headers, vulkan-loader-android"
TERMUX_PKG_BUILD_IN_SRC=true
# Chromium doesn't support i686 on Linux.
TERMUX_PKG_BLACKLISTED_ARCHES="i686"

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
# (1) Set google keys
# (2) Enable GUI (non-headless)
# (3) Use system libraries when possible
# (4) Enable Sandbox (AFAIK this is impossible)

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

	_DUMMY_FILES=()

	# Dummy librt.so
	# Why not dummy a librt.a? Some of the binaries reference symbols in `android/log.h`
	# for some reason, such as the `chrome_crashpad_handler`, which needs to link with 
	# libprotobuf_lite.a, but it is hard to remove the usage of `android/log.h` in protobuf. 
	echo "INPUT(-llog)" > "$TERMUX_PREFIX/lib/librt.so"
	_DUMMY_FILES+=("$TERMUX_PREFIX/lib/librt.so")

	# Dummy libpthread.a
	echo '!<arch>' > "$TERMUX_PREFIX/lib/libpthread.a"
	_DUMMY_FILES+=("$TERMUX_PREFIX/lib/libpthread.a")

	# Dummy libresolv.a
	echo '!<arch>' > "$TERMUX_PREFIX/lib/libresolv.a"
	_DUMMY_FILES+=("$TERMUX_PREFIX/lib/libresolv.a")

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

	local _TARGET_CPU="$TERMUX_ARCH"
	if [ "$TERMUX_ARCH" = "aarch64" ]; then
		_TARGET_CPU="arm64"
	elif [ "$TERMUX_ARCH" = "x86_64" ]; then
		_TARGET_CPU="x64"
	fi

	mkdir -p out/Headless
	rm -rf out/Headless/args.gn
	echo "
import(\"//build/args/headless.gn\")
target_cpu = \"$_TARGET_CPU\"
target_rpath = \"$TERMUX_PREFIX/lib\"
target_sysroot = \"$TERMUX_PKG_TMPDIR/sysroot\"
custom_toolchain = \"//build/toolchain/linux/unbundle:default\"
use_sysroot = false
is_debug = false
clang_base_path = \"$TERMUX_STANDALONE_TOOLCHAIN\"
clang_use_chrome_plugins = false
dcheck_always_on = false
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
" > out/Headless/args.gn

	# For arm, we need to tell GN to choose a host-provided clang toolchain.
	if [ "$TERMUX_ARCH" = "arm" ]; then
		echo "arm_arch = \"armv7-a\"" >> out/Headless/args.gn
		echo "arm_float_abi = \"softfp\"" >> out/Headless/args.gn
		# When generating the v8 snapshot, GN will try to use `clang-14` from the ndk
		# toolchain, and then `lld` will fail because of the linkage with an *invalid*
		# `libatomic.a` which is located at `lib64/clang/x.y.z/lib/linux/i386`.
		local _clang_version="$($TERMUX_STANDALONE_TOOLCHAIN/bin/clang --version | head -n 1 | sed 's/.*version \([0-9]*.[0-9]*.[0-9]*\) .*/\1/g')"
		local _invalid_atomic="$TERMUX_STANDALONE_TOOLCHAIN/lib64/clang/$_clang_version/lib/linux/i386/libatomic.a"
		if [ -f "$_invalid_atomic" ]; then
			mv $_invalid_atomic{,.backup}
		fi
	fi

	# When building for x64, these variables must be set to tell
	# GN that we are at cross-compiling.
	if [ "$TERMUX_ARCH" = "x86_64" ]; then
		mkdir -p $TERMUX_PKG_TMPDIR/host-toolchain
		pushd $TERMUX_PKG_TMPDIR/host-toolchain
		sed "s|@COMPILER@|$(command -v clang-13)|g" $TERMUX_PKG_BUILDER_DIR/wrapper-compiler.in > ./wrapper_cc
		sed "s|@COMPILER@|$(command -v clang++-13)|g" $TERMUX_PKG_BUILDER_DIR/wrapper-compiler.in > ./wrapper_cxx
		chmod +x ./wrapper_cc ./wrapper_cxx
		popd

		export BUILD_CC=$TERMUX_PKG_TMPDIR/host-toolchain/wrapper_cc
		export BUILD_CXX=$TERMUX_PKG_TMPDIR/host-toolchain/wrapper_cxx
		export BUILD_AR=$(command -v llvm-ar)
		export BUILD_NM=$(command -v llvm-nm)

		export BUILD_CFLAGS="--target=x86_64-linux-gnu"
		export BUILD_CPPFLAGS=""
		export BUILD_CXXFLAGS="--target=x86_64-linux-gnu"
		export BUILD_LDFLAGS="--target=x86_64-linux-gnu"

		echo "host_toolchain = \"//build/toolchain/linux/unbundle:host\"" >> out/Headless/args.gn
		echo "v8_snapshot_toolchain = \"//build/toolchain/linux/unbundle:host\"" >> out/Headless/args.gn
	fi

	gn gen out/Headless --export-compile-commands
}

termux_step_make() {
	ninja -C out/Headless headless_shell -j $TERMUX_MAKE_PROCESSES
}

termux_step_make_install() {
	local headless_files=(
		# Binary files
		chrome_crashpad_handler
		headless_shell

		# Resource files
		headless_lib_data.pak
		headless_lib_strings.pak

		# Angle
		libEGL.so
		libGLESv2.so

		# Vulkan
		libvulkan.so.1
		libVkICD_mock_icd.so
		libvk_swiftshader.so
		libVkLayer_khronos_validation.so
		vk_swiftshader_icd.json
	)
	mkdir -p $TERMUX_PREFIX/lib/chromium
	cp "${headless_files[@]/#/out/Headless/}" "$TERMUX_PREFIX/lib/chromium/"
	cp -Rf out/Headless/angledata $TERMUX_PREFIX/lib/chromium/
	cp -Rf out/Headless/resources $TERMUX_PREFIX/lib/chromium/
	ln -sfr $TERMUX_PREFIX/lib/chromium/headless_shell $TERMUX_PREFIX/bin/
}

termux_step_post_make_install() {
	# Remove the dummy files
	rm "${_DUMMY_FILES[@]}"
	unset _DUMMY_FILES
	# Recover the toolchain
	local _clang_version="$($TERMUX_STANDALONE_TOOLCHAIN/bin/clang --version | head -n 1 | sed 's/.*version \([0-9]*.[0-9]*.[0-9]*\) .*/\1/g')"
	local _invalid_atomic="$TERMUX_STANDALONE_TOOLCHAIN/lib64/clang/$_clang_version/lib/linux/i386/libatomic.a"
	if [ -f "$_invalid_atomic.backup" ]; then
		mv $_invalid_atomic{.backup,}
	fi
}

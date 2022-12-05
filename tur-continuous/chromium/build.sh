TERMUX_PKG_HOMEPAGE=https://www.chromium.org/Home
TERMUX_PKG_DESCRIPTION="Chromium web browser"
TERMUX_PKG_LICENSE="BSD 3-Clause"
TERMUX_PKG_MAINTAINER="Chongyun Lee <uchkks@protonmail.com>"
_CHROMIUM_VERSION=107.0.5304.107
TERMUX_PKG_VERSION=$_CHROMIUM_VERSION
TERMUX_PKG_SRCURL=(https://commondatastorage.googleapis.com/chromium-browser-official/chromium-$_CHROMIUM_VERSION.tar.xz)
TERMUX_PKG_SHA256=(49d96b1247690b5ecc061d91fdb203eaef38c6d6e1bb60ca4472eaa99bba1a3e)
TERMUX_PKG_DEPENDS="atk, cups, dbus, fontconfig, freetype, gtk3, krb5, libc++, libdrm, libxkbcommon, libminizip, libnss, libwayland, libjpeg-turbo, libpng, libx11, mesa-chromium, openssl, pango, qt5-qtbase, vulkan-loader-android, zlib"
# TODO: Split chromium-common and chromium-headless
# TERMUX_PKG_DEPENDS+=", chromium-common"
# TERMUX_PKG_SUGGESTS="chromium-headless, chromium-driver"
TERMUX_PKG_BUILD_DEPENDS="vulkan-headers, qt5-qtbase-cross-tools"
TERMUX_PKG_BUILD_IN_SRC=true
# Chromium doesn't support i686 on Linux.
TERMUX_PKG_BLACKLISTED_ARCHES="i686"

SYSTEM_LIBRARIES="
libdrm
libjpeg
libpng
fontconfig
freetype
zlib
"

# TERMUX_PKG_DEPENDS+=", harfbuzz, libdav1d"
# `harfbuzz-ng` and `dav1d` cannot be used as system libraries because
# Google-provided rootfs doesn't have these libraries. Maybe we should
# construct our own rootfs later.

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

	################################################################
	# Please dont use these keys outside of Termux User Repository #
	# You can create your own at:                                  #
	# http://www.chromium.org/developers/how-tos/api-keys          #
	################################################################
	local _google_api_key _google_default_client_id _google_default_client_secret
	eval "$(base64 -d < $TERMUX_PKG_BUILDER_DIR/google-api-keys.base64enc)"

	# Remove termux's dummy pkg-config
	local _host_pkg_config="$(cat $(command -v pkg-config) | grep exec | awk '{print $2}')"
	rm -rf $TERMUX_PKG_TMPDIR/host-pkg-config-bin
	mkdir -p $TERMUX_PKG_TMPDIR/host-pkg-config-bin
	ln -s $_host_pkg_config $TERMUX_PKG_TMPDIR/host-pkg-config-bin
	export PATH="$TERMUX_PKG_TMPDIR/host-pkg-config-bin:$PATH"

	env -i PATH="$PATH" sudo apt update
	env -i PATH="$PATH" sudo apt install libdrm-dev libjpeg-turbo8-dev libpng-dev fontconfig libfontconfig-dev libfontconfig1-dev libfreetype6-dev zlib1g-dev libcups2-dev libxkbcommon-dev libglib2.0-dev -yq
	env -i PATH="$PATH" sudo apt install libdrm-dev:i386 libjpeg-turbo8-dev:i386 libpng-dev:i386 libfontconfig-dev:i386 libfontconfig1-dev:i386 libfreetype6-dev:i386 zlib1g-dev:i386 libcups2-dev:i386 libglib2.0-dev:i386 libxkbcommon-dev:i386 -yq

	# Install amd64 rootfs
	build/linux/sysroot_scripts/install-sysroot.py --arch=amd64

	# Link to system tools required by the build
	mkdir -p third_party/node/linux/node-linux-x64/bin
	ln -sf $(command -v node) third_party/node/linux/node-linux-x64/bin/
	ln -sf $(command -v java) third_party/jdk/current/bin/

	_DUMMY_FILES=()

	# Dummy librt.so
	# Why not dummy a librt.a? Some of the binaries reference symbols only exists in Android
	# for some reason, such as the `chrome_crashpad_handler`, which needs to link with 
	# libprotobuf_lite.a, but it is hard to remove the usage of `android/log.h` in protobuf.
	echo "INPUT(-llog -liconv -landroid-shmem)" > "$TERMUX_PREFIX/lib/librt.so"
	_DUMMY_FILES+=("$TERMUX_PREFIX/lib/librt.so")

	# Dummy libpthread.a
	echo '!<arch>' > "$TERMUX_PREFIX/lib/libpthread.a"
	_DUMMY_FILES+=("$TERMUX_PREFIX/lib/libpthread.a")

	# Dummy libresolv.a
	echo '!<arch>' > "$TERMUX_PREFIX/lib/libresolv.a"
	_DUMMY_FILES+=("$TERMUX_PREFIX/lib/libresolv.a")

	# Merge sysroots
	rm -rf $TERMUX_PKG_TMPDIR/sysroot
	mkdir -p $TERMUX_PKG_TMPDIR/sysroot
	pushd $TERMUX_PKG_TMPDIR/sysroot
	mkdir -p usr/include usr/lib usr/bin
	cp -R $TERMUX_STANDALONE_TOOLCHAIN/sysroot/usr/include/* usr/include
	cp -R $TERMUX_STANDALONE_TOOLCHAIN/sysroot/usr/include/$TERMUX_HOST_PLATFORM/* usr/include
	cp -R $TERMUX_STANDALONE_TOOLCHAIN/sysroot/usr/lib/$TERMUX_HOST_PLATFORM/$TERMUX_PKG_API_LEVEL/* usr/lib/
	cp "$TERMUX_STANDALONE_TOOLCHAIN/sysroot/usr/lib/$TERMUX_HOST_PLATFORM/libc++_shared.so" usr/lib/
	cp "$TERMUX_STANDALONE_TOOLCHAIN/sysroot/usr/lib/$TERMUX_HOST_PLATFORM/libc++_static.a" usr/lib/
	cp "$TERMUX_STANDALONE_TOOLCHAIN/sysroot/usr/lib/$TERMUX_HOST_PLATFORM/libc++abi.a" usr/lib/
	cp -Rf $TERMUX_PREFIX/include/* usr/include
	cp -Rf $TERMUX_PREFIX/lib/* usr/lib
	ln -sf /data ./data
	# Use mesa's EGL
	rm -r usr/include/EGL
	cp -R $TERMUX_PREFIX/opt/mesa-chromium/* usr/
	# This is needed to build crashpad
	rm -rf $TERMUX_PREFIX/include/spawn.h
	# This is needed to build cups
	cp -Rf $TERMUX_PREFIX/bin/cups-config usr/bin/
	chmod +x usr/bin/cups-config
	popd

	export LDFLAGS="-Wl,-rpath=$TERMUX_PREFIX/opt/mesa-chromium/lib $LDFLAGS"

	local _TARGET_CPU="$TERMUX_ARCH"
	if [ "$TERMUX_ARCH" = "aarch64" ]; then
		_TARGET_CPU="arm64"
	elif [ "$TERMUX_ARCH" = "x86_64" ]; then
		_TARGET_CPU="x64"
	fi

	local _common_args_file=$TERMUX_PKG_TMPDIR/common-args-file
	rm -f $_common_args_file
	touch $_common_args_file

	echo "
use_sysroot = true
target_cpu = \"$_TARGET_CPU\"
target_rpath = \"$TERMUX_PREFIX/lib\"
target_sysroot = \"$TERMUX_PKG_TMPDIR/sysroot\"
custom_toolchain = \"//build/toolchain/linux/unbundle:default\"
is_debug = false
clang_base_path = \"$TERMUX_STANDALONE_TOOLCHAIN\"
clang_use_chrome_plugins = false
dcheck_always_on = false
chrome_pgo_phase = 0
treat_warnings_as_errors = false
use_system_freetype = true
use_system_libdrm = true
use_system_libffi = true
use_system_libjpeg = true
use_system_libpng = true
use_system_zlib = true
use_custom_libcxx = false
use_allocator_shim = false
use_allocator = \"none\"
use_nss_certs = true
is_official_build = false
use_udev = false
google_api_key = \"$_google_api_key\"
google_default_client_id = \"$_google_default_client_id\"
google_default_client_secret = \"$_google_default_client_secret\"
" > $_common_args_file

	# For aarch64, remove the `libatomic.a` in `NDK Toolchain` for x86_64
	if [ "$TERMUX_ARCH" = "aarch64" ]; then
		# When generating the v8 snapshot, GN will try to use `clang-14` from the ndk
		# toolchain, and then `lld` will fail because of the linkage with an *invalid*
		# `libatomic.a` which is located at `lib64/clang/x.y.z/lib/linux/x86_64`.
		local _clang_version="$($TERMUX_STANDALONE_TOOLCHAIN/bin/clang --version | head -n 1 | sed 's/.*version \([0-9]*.[0-9]*.[0-9]*\) .*/\1/g')"
		local _invalid_atomic="$TERMUX_STANDALONE_TOOLCHAIN/lib64/clang/$_clang_version/lib/linux/x86_64/libatomic.a"
		if [ -f "$_invalid_atomic" ]; then
			mv $_invalid_atomic{,.backup}
		fi
	fi

	# For arm, remove the `libatomic.a` in `NDK Toolchain` for i686
	if [ "$TERMUX_ARCH" = "arm" ]; then
		echo "arm_arch = \"armv7-a\"" >> $_common_args_file
		echo "arm_float_abi = \"softfp\"" >> $_common_args_file
		# Install i386 rootfs
		build/linux/sysroot_scripts/install-sysroot.py --arch=i386
		# Remove the *invalid* `libatomic.a`
		local _clang_version="$($TERMUX_STANDALONE_TOOLCHAIN/bin/clang --version | head -n 1 | sed 's/.*version \([0-9]*.[0-9]*.[0-9]*\) .*/\1/g')"
		local _invalid_atomic="$TERMUX_STANDALONE_TOOLCHAIN/lib64/clang/$_clang_version/lib/linux/i386/libatomic.a"
		if [ -f "$_invalid_atomic" ]; then
			mv $_invalid_atomic{,.backup}
		fi
		# FIXME: Disable nacl on arm due to the following error. Need to figure out why this happens.
		# FIXME: ninja: error: '../../native_client/toolchain/linux_x86/pnacl_newlib/bin/arm-nacl-objcopy', needed by 'nacl_irt_arm.nexe', missing and no known rule to make it
		echo "enable_nacl = false" >> $_common_args_file
	fi

	# When building for x64, these variables must be set to tell
	# GN that we are at cross-compiling.
	if [ "$TERMUX_ARCH" = "x86_64" ]; then
		mkdir -p $TERMUX_PKG_TMPDIR/host-toolchain
		local _sysroot_path="$(pwd)/build/linux/$(ls build/linux | grep 'amd64-sysroot')"
		pushd $TERMUX_PKG_TMPDIR/host-toolchain
		sed "s|@COMPILER@|$(command -v clang-13)|" $TERMUX_PKG_BUILDER_DIR/wrapper-compiler.in |
			sed "s|@NEW_SYSROOT@|$_sysroot_path|;s|@TERMUX_PREFIX@|$TERMUX_PREFIX|" > ./wrapper_cc
		sed "s|@COMPILER@|$(command -v clang++-13)|" $TERMUX_PKG_BUILDER_DIR/wrapper-compiler.in |
			sed "s|@NEW_SYSROOT@|$_sysroot_path|;s|@TERMUX_PREFIX@|$TERMUX_PREFIX|" > ./wrapper_cxx
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

		echo "host_toolchain = \"//build/toolchain/linux/unbundle:host\"" >> $_common_args_file
		echo "v8_snapshot_toolchain = \"//build/toolchain/linux/unbundle:host\"" >> $_common_args_file
		# FIXME: Disable nacl on x86_64 due to the error above.
		echo "enable_nacl = false" >> $_common_args_file
	fi

	# Headless Chromium
	# mkdir -p out/Headless
	# rm -f out/Headless/args.gn
	# echo "import(\"//build/args/headless.gn\")" > out/Headless/args.gn
	# cat $_common_args_file >> out/Headless/args.gn
	# gn gen out/Headless --export-compile-commands || bash

	# Chromium Binary
	mkdir -p out/Release
	rm -f out/Release/args.gn
	cat $_common_args_file >> out/Release/args.gn
	echo "
use_ozone = true
ozone_auto_platforms = false
ozone_platform = \"x11\"
ozone_platform_x11 = true
ozone_platform_wayland = true
ozone_platform_headless = true
angle_enable_vulkan = true
angle_enable_swiftshader = true
use_gnome_keyring = false
use_qt = true
use_libpci = false
use_alsa = false
use_pulseaudio = false
rtc_use_pipewire = false
use_vaapi_x11 = false
" >> out/Release/args.gn
	gn gen out/Release --export-compile-commands
}

termux_step_make() {
	ninja -C out/Release chromedriver chrome chrome_crashpad_handler headless_shell || bash
}

termux_step_make_install() {
	mkdir -p $TERMUX_PREFIX/lib/chromium

	local normal_files=(
		# Binary files
		chrome
		chrome_crashpad_handler
		headless_shell
		chromedriver
		generate_colors_info

		# Resource files
		chrome_100_percent.pak
		chrome_200_percent.pak
		headless_lib_data.pak
		headless_lib_strings.pak
		resources.pak

		# V8 Snapshot data
		snapshot_blob.bin
		v8_context_snapshot.bin

		# ICU Data
		icudtl.dat

		# Logo
		product_logo_48.png

		# Scripts
		chrome-wrapper
		xdg-mime
		xdg-settings

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

	cp "${normal_files[@]/#/out/Release/}" "$TERMUX_PREFIX/lib/chromium/"

	cp -Rf out/Release/angledata $TERMUX_PREFIX/lib/chromium/
	cp -Rf out/Release/locales $TERMUX_PREFIX/lib/chromium/
	cp -Rf out/Release/MEIPreload $TERMUX_PREFIX/lib/chromium/
	cp -Rf out/Release/resources $TERMUX_PREFIX/lib/chromium/

	ln -sfr $TERMUX_PREFIX/lib/chromium/chrome $TERMUX_PREFIX/bin/
	ln -sfr $TERMUX_PREFIX/lib/chromium/chromedriver $TERMUX_PREFIX/bin/
	ln -sfr $TERMUX_PREFIX/lib/chromium/headless_shell $TERMUX_PREFIX/bin/
}

termux_step_post_make_install() {
	# Remove the dummy files
	rm "${_DUMMY_FILES[@]}"
	unset _DUMMY_FILES

	# Recover the toolchain
	for _arch in i386 x86_64; do
		local _clang_version="$($TERMUX_STANDALONE_TOOLCHAIN/bin/clang --version | head -n 1 | sed 's/.*version \([0-9]*.[0-9]*.[0-9]*\) .*/\1/g')"
		local _invalid_atomic="$TERMUX_STANDALONE_TOOLCHAIN/lib64/clang/$_clang_version/lib/linux/$_arch/libatomic.a"
		if [ -f "$_invalid_atomic.backup" ]; then
			mv $_invalid_atomic{.backup,}
		fi
	done
	unset _arch
}

# TODO:
# (1) Split packages
# (2) Use system libraries as much as possible
# (3) Enable ffmpeg
# (4) Enable Sandbox (AFAIK this is impossible)
# (5) Package man pages
# (6) Enable pulseaudio
# (7) Use libreolv-wrapper
# (8) Refator the GN files (Add a variant is_termux in the configure files)
# (9) Figure out what packages in vulkan and mesa are actually needed
# (10) Figure out why nacl cannot be enabled

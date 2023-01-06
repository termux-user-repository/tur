TERMUX_PKG_HOMEPAGE=https://github.com/electron/electron
TERMUX_PKG_DESCRIPTION="Build cross-platform desktop apps with JavaScript, HTML, and CSS"
TERMUX_PKG_LICENSE="MIT, BSD 3-Clause"
TERMUX_PKG_MAINTAINER="Chongyun Lee <uchkks@protonmail.com>"
_CHROMIUM_VERSION=106.0.5249.199
TERMUX_PKG_VERSION=21.3.3
TERMUX_PKG_REVISION=3
TERMUX_PKG_SRCURL=git+https://github.com/electron/electron
TERMUX_PKG_DEPENDS="electron-deps"
TERMUX_PKG_BUILD_DEPENDS="libnotify"
# Chromium doesn't support i686 on Linux.
TERMUX_PKG_BLACKLISTED_ARCHES="i686"

termux_step_get_source() {
	# Check whether we need to get source
	if [ -f "$TERMUX_PKG_CACHEDIR/.electron-source-fetched" ]; then
		local _fetched_source_version=$(cat $TERMUX_PKG_CACHEDIR/.electron-source-fetched)
		if [ "$_fetched_source_version" = "$TERMUX_PKG_VERSION" ]; then
			echo "[INFO]: Use pre-fetched source (version $_fetched_source_version)."
			ln -sfr $TERMUX_PKG_CACHEDIR/tmp-checkout/src $TERMUX_PKG_SRCDIR
			# Revert patches
			shopt -s nullglob
			local f
			for f in $TERMUX_PKG_BUILDER_DIR/*.patch; do
				echo "[INFO]: Reverting $(basename "$f")"
				(sed "s|@TERMUX_PREFIX@|$TERMUX_PREFIX|g" "$f" | patch -f --silent -R -p1 -d "$TERMUX_PKG_SRCDIR") || true
			done
			shopt -u nullglob
			python $TERMUX_SCRIPTDIR/common-files/apply-chromium-patches.py -C "$TERMUX_PKG_SRCDIR" -R -v $_CHROMIUM_VERSION || bash
			return
		fi
	fi

	# Fetch depot_tools
	if [ ! -f "$TERMUX_PKG_CACHEDIR/.depot_tools-fetched" ];then
		git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git $TERMUX_PKG_CACHEDIR/depot_tools
		touch "$TERMUX_PKG_CACHEDIR/.depot_tools-fetched"
	fi
	export PATH="$TERMUX_PKG_CACHEDIR/depot_tools:$PATH"

	# Install nodejs
	termux_setup_nodejs

	# Get source
	rm -rf "$TERMUX_PKG_CACHEDIR/tmp-checkout"
	mkdir -p "$TERMUX_PKG_CACHEDIR/tmp-checkout"
	pushd "$TERMUX_PKG_CACHEDIR/tmp-checkout"
	gclient config --name "src/electron" --unmanaged https://github.com/electron/electron
	gclient sync --with_branch_heads --with_tags --no-history --revision v$TERMUX_PKG_VERSION || bash
	popd

	# Solve error like `.git/packed-refs is dirty`
	cd "$TERMUX_PKG_CACHEDIR/tmp-checkout/src"
	git pack-refs --all
	cd electron
	git pack-refs --all

	echo "$TERMUX_PKG_VERSION" > "$TERMUX_PKG_CACHEDIR/.electron-source-fetched"
	ln -sfr $TERMUX_PKG_CACHEDIR/tmp-checkout/src $TERMUX_PKG_SRCDIR
}

termux_step_post_get_source() {
	echo "$TERMUX_PKG_VERSION" > $TERMUX_PKG_SRCDIR/electron/ELECTRON_VERSION
	python $TERMUX_SCRIPTDIR/common-files/apply-chromium-patches.py -v $_CHROMIUM_VERSION
}

termux_step_configure() {
	cd $TERMUX_PKG_SRCDIR
	termux_setup_gn
	termux_setup_ninja
	termux_setup_nodejs

	# Remove termux's dummy pkg-config
	local _host_pkg_config="$(cat $(command -v pkg-config) | grep exec | awk '{print $2}')"
	rm -rf $TERMUX_PKG_TMPDIR/host-pkg-config-bin
	mkdir -p $TERMUX_PKG_TMPDIR/host-pkg-config-bin
	ln -s $_host_pkg_config $TERMUX_PKG_TMPDIR/host-pkg-config-bin
	export PATH="$TERMUX_PKG_TMPDIR/host-pkg-config-bin:$PATH"

	env -i PATH="$PATH" sudo apt update
	env -i PATH="$PATH" sudo apt install libdrm-dev libjpeg-turbo8-dev libpng-dev fontconfig libfontconfig-dev libfontconfig1-dev libfreetype6-dev zlib1g-dev libcups2-dev libxkbcommon-dev libglib2.0-dev -yq
	env -i PATH="$PATH" sudo apt install libdrm-dev:i386 libjpeg-turbo8-dev:i386 libpng-dev:i386 libfontconfig-dev:i386 libfontconfig1-dev:i386 libfreetype6-dev:i386 zlib1g-dev:i386 libcups2-dev:i386 libglib2.0-dev:i386 libxkbcommon-dev:i386 -yq

	# Install amd64 rootfs if necessary, it should have been installed by source hooks.
	build/linux/sysroot_scripts/install-sysroot.py --arch=amd64

	# Link to system tools required by the build
	mkdir -p third_party/node/linux/node-linux-x64/bin
	ln -sf $(command -v node) third_party/node/linux/node-linux-x64/bin/

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
	# This is needed to build cups
	cp -Rf $TERMUX_PREFIX/bin/cups-config usr/bin/
	chmod +x usr/bin/cups-config
	popd

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
import(\"//electron/build/args/release.gn\")
# Do not build with symbols
symbol_level = 0
# Use our custom toolchain
use_sysroot = true
target_cpu = \"$_TARGET_CPU\"
target_rpath = \"$TERMUX_PREFIX/lib\"
target_sysroot = \"$TERMUX_PKG_TMPDIR/sysroot\"
custom_toolchain = \"//build/toolchain/linux/unbundle:default\"
clang_base_path = \"$TERMUX_STANDALONE_TOOLCHAIN\"
clang_use_chrome_plugins = false
dcheck_always_on = false
chrome_pgo_phase = 0
treat_warnings_as_errors = false
# Use system libraries as little as possible
use_bundled_fontconfig = false
use_system_freetype = true
use_system_libdrm = true
use_custom_libcxx = false
use_allocator_shim = false
use_allocator = \"none\"
use_nss_certs = true
use_udev = false
use_gnome_keyring = false
use_alsa = false
use_libpci = false
use_pulseaudio = true
use_ozone = true
ozone_auto_platforms = false
ozone_platform = \"x11\"
ozone_platform_x11 = true
ozone_platform_wayland = true
ozone_platform_headless = true
angle_enable_vulkan = true
angle_enable_swiftshader = true
rtc_use_pipewire = false
use_vaapi_x11 = false
# See comments on Chromium package
enable_nacl = false
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
		# Install i386 rootfs if necessary, it should have been installed by source hooks.
		build/linux/sysroot_scripts/install-sysroot.py --arch=i386
		# Remove the *invalid* `libatomic.a`
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
	fi

	mkdir -p $TERMUX_PKG_BUILDDIR/out/Release
	cat $_common_args_file > $TERMUX_PKG_BUILDDIR/out/Release/args.gn
	gn gen $TERMUX_PKG_BUILDDIR/out/Release --export-compile-commands || bash
}

termux_step_make() {
	cd $TERMUX_PKG_BUILDDIR
	ninja -C $TERMUX_PKG_BUILDDIR/out/Release electron electron_license chromium_licenses || bash
}

termux_step_make_install() {
	cd $TERMUX_PKG_BUILDDIR
	mkdir -p $TERMUX_PREFIX/lib/electron

	echo "$TERMUX_PKG_VERSION" > $TERMUX_PKG_BUILDDIR/out/Release/version

	local normal_files=(
		# Binary files
		electron
		chrome_sandbox
		chrome_crashpad_handler

		# Resource files
		chrome_100_percent.pak
		chrome_200_percent.pak
		resources.pak

		# V8 Snapshot data
		snapshot_blob.bin
		v8_context_snapshot.bin

		# ICU Data
		icudtl.dat

		# Angle
		libEGL.so
		libGLESv2.so

		# Vulkan
		libvulkan.so.1
		libvk_swiftshader.so
		vk_swiftshader_icd.json

		# FFmpeg
		libffmpeg.so

		# VERSION file
		version
	)

	cp "${normal_files[@]/#/out/Release/}" "$TERMUX_PREFIX/lib/electron/"

	cp -Rf out/Release/angledata $TERMUX_PREFIX/lib/electron/
	cp -Rf out/Release/locales $TERMUX_PREFIX/lib/electron/
	cp -Rf out/Release/resources $TERMUX_PREFIX/lib/electron/

	chmod +x $TERMUX_PREFIX/lib/electron/electron
	ln -sfr $TERMUX_PREFIX/lib/electron/electron $TERMUX_PREFIX/bin/electron

	# Install LICENSE file
	mkdir -p $TERMUX_PREFIX/share/doc/electron
	cp out/Release/LICENSE{,S.chromium.html} $TERMUX_PREFIX/share/doc/electron
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

TERMUX_PKG_HOMEPAGE=https://github.com/fathyb/carbonyl
TERMUX_PKG_DESCRIPTION="Chromium based browser built to run in a terminal"
TERMUX_PKG_LICENSE="BSD 3-Clause"
TERMUX_PKG_LICENSE_FILE="license.md"
TERMUX_PKG_MAINTAINER="Chongyun Lee <uchkks@protonmail.com>"
_CHROMIUM_VERSION=110.0.5481.177
TERMUX_PKG_VERSION=0.0.3
TERMUX_PKG_SRCURL=(https://github.com/fathyb/carbonyl/archive/refs/tags/v$TERMUX_PKG_VERSION.tar.gz)
TERMUX_PKG_SRCURL+=(https://commondatastorage.googleapis.com/chromium-browser-official/chromium-$_CHROMIUM_VERSION.tar.xz)
TERMUX_PKG_SHA256=(bf421b9498a084a7cf2238a574d37d31b498d3e271fdb3dcf466e7ed6c80013d)
TERMUX_PKG_SHA256+=(7b2f454d1195270a39f94a9ff6d8d68126be315e0da4e31c20f4ba9183a1c9b7)
TERMUX_PKG_DEPENDS="electron-deps"
TERMUX_PKG_BUILD_DEPENDS="libnotify, libffi-static"
# Chromium doesn't support i686 on Linux.
# Carbonyl donesn't support arm.
TERMUX_PKG_BLACKLISTED_ARCHES="arm, i686"

termux_step_post_get_source() {
	# Move chromium source
	mv chromium-$_CHROMIUM_VERSION chromium/src

	# Apply diffs
	for f in $(find "$TERMUX_PKG_BUILDER_DIR/" -maxdepth 1 -type f -name *.diff | sort); do
		echo "Applying patch: $(basename $f)"
		patch -p1 < "$f"
	done

	# Apply patches related to chromium
	pushd chromium/src
	python $TERMUX_SCRIPTDIR/common-files/apply-chromium-patches.py -v $_CHROMIUM_VERSION
	popd

	# Apply patches related to carbonyl
	pushd chromium/src
	for f in $(find "$TERMUX_PKG_SRCDIR/chromium/patches/chromium/" -maxdepth 1 -type f -name *.patch | sort); do
		echo "Applying patch: $(basename $f)"
		patch --silent -p1 < "$f"
	done
	popd

	pushd chromium/src/third_party/skia
	for f in $(find "$TERMUX_PKG_SRCDIR/chromium/patches/skia/" -maxdepth 1 -type f -name *.diff | sort); do
		echo "Applying patch: $(basename $f)"
		patch --silent -p1 < "$f"
	done
	popd

	pushd chromium/src/third_party/webrtc
	for f in $(find "$TERMUX_PKG_SRCDIR/chromium/patches/webrtc/" -maxdepth 1 -type f -name *.diff | sort); do
		echo "Applying patch: $(basename $f)"
		patch --silent -p1 < "$f"
	done
	popd
}

termux_step_configure() {
	cd $TERMUX_PKG_SRCDIR/chromium/src
	termux_setup_ninja
	termux_setup_gn
	termux_setup_nodejs

	# Remove termux's dummy pkg-config
	local _target_pkg_config=$(command -v pkg-config)
	local _host_pkg_config="$(cat $_target_pkg_config | grep exec | awk '{print $2}')"
	rm -rf $TERMUX_PKG_TMPDIR/host-pkg-config-bin
	mkdir -p $TERMUX_PKG_TMPDIR/host-pkg-config-bin
	ln -s $_host_pkg_config $TERMUX_PKG_TMPDIR/host-pkg-config-bin/pkg-config
	export PATH="$TERMUX_PKG_TMPDIR/host-pkg-config-bin:$PATH"

	env -i PATH="$PATH" sudo apt update
	env -i PATH="$PATH" sudo apt install libdrm-dev libjpeg-turbo8-dev libpng-dev fontconfig libfontconfig-dev libfontconfig1-dev libfreetype6-dev zlib1g-dev libcups2-dev libxkbcommon-dev libglib2.0-dev -yq
	env -i PATH="$PATH" sudo apt install libdrm-dev:i386 libjpeg-turbo8-dev:i386 libpng-dev:i386 libfontconfig-dev:i386 libfontconfig1-dev:i386 libfreetype6-dev:i386 zlib1g-dev:i386 libcups2-dev:i386 libglib2.0-dev:i386 libxkbcommon-dev:i386 -yq

	# Install amd64 rootfs if necessary, it should have been installed by source hooks.
	build/linux/sysroot_scripts/install-sysroot.py --arch=amd64
	local _amd64_sysroot_path="$(pwd)/build/linux/$(ls build/linux | grep 'amd64-sysroot')"

	# Install i386 rootfs if necessary, it should have been installed by source hooks.
	build/linux/sysroot_scripts/install-sysroot.py --arch=i386
	local _i386_sysroot_path="$(pwd)/build/linux/$(ls build/linux | grep 'i386-sysroot')"

	# Link to system tools required by the build
	mkdir -p third_party/node/linux/node-linux-x64/bin
	ln -sf $(command -v node) third_party/node/linux/node-linux-x64/bin/
	ln -sf $(command -v java) third_party/jdk/current/bin/

	# Dummy librt.so
	# Why not dummy a librt.a? Some of the binaries reference symbols only exists in Android
	# for some reason, such as the `chrome_crashpad_handler`, which needs to link with 
	# libprotobuf_lite.a, but it is hard to remove the usage of `android/log.h` in protobuf.
	echo "INPUT(-llog -liconv -landroid-shmem)" > "$TERMUX_PREFIX/lib/librt.so"

	# Dummy libpthread.a and libresolv.a
	echo '!<arch>' > "$TERMUX_PREFIX/lib/libpthread.a"
	echo '!<arch>' > "$TERMUX_PREFIX/lib/libresolv.a"

	# Symlink libffi.a to libffi_pic.a
	ln -sfr $TERMUX_PREFIX/lib/libffi.a $TERMUX_PREFIX/lib/libffi_pic.a

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

	# Construct args
	local _target_cpu _v8_current_cpu _v8_sysroot_path
	local _v8_toolchain_name _target_sysroot="$TERMUX_PKG_TMPDIR/sysroot"
	if [ "$TERMUX_ARCH" = "aarch64" ]; then
		_target_cpu="arm64"
		_v8_current_cpu="x64"
		_v8_sysroot_path="$_amd64_sysroot_path"
		_v8_toolchain_name="clang_x64_v8_arm64"
	elif [ "$TERMUX_ARCH" = "arm" ]; then
		_target_cpu="arm"
		_v8_current_cpu="x86"
		_v8_sysroot_path="$_i386_sysroot_path"
		_v8_toolchain_name="clang_x86_v8_arm"
	elif [ "$TERMUX_ARCH" = "x86_64" ]; then
		_target_cpu="x64"
		_v8_current_cpu="x64"
		_v8_sysroot_path="$_amd64_sysroot_path"
		_v8_toolchain_name="clang_x64"
	fi

	local _common_args_file=$TERMUX_PKG_TMPDIR/common-args-file
	rm -f $_common_args_file
	touch $_common_args_file

	echo "
import(\"//carbonyl/src/browser/args.gn\")
# Do not build with symbols
is_debug = false
is_component_build = false
symbol_level = 0
# Use our custom toolchain
use_sysroot = false
target_cpu = \"$_target_cpu\"
target_rpath = \"$TERMUX_PREFIX/lib\"
target_sysroot = \"$_target_sysroot\"
clang_base_path = \"$TERMUX_STANDALONE_TOOLCHAIN\"
custom_toolchain = \"//build/toolchain/linux/unbundle:default\"
host_toolchain = \"$TERMUX_PKG_CACHEDIR/custom-toolchain:host\"
v8_snapshot_toolchain = \"$TERMUX_PKG_CACHEDIR/custom-toolchain:$_v8_toolchain_name\"
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
use_partition_alloc_as_malloc = false
enable_backup_ref_ptr_support = false
enable_mte_checked_ptr_support = false
use_nss_certs = true
use_udev = false
use_gnome_keyring = false
use_alsa = false
use_libpci = false
use_pulseaudio = true
use_ozone = true
use_qt = false
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
use_thin_lto=false
" >> $_common_args_file

	if [ "$TERMUX_ARCH" = "arm" ]; then
		echo "arm_arch = \"armv7-a\"" >> $_common_args_file
		echo "arm_float_abi = \"softfp\"" >> $_common_args_file
	fi

	# Use custom toolchain
	mkdir -p $TERMUX_PKG_CACHEDIR/custom-toolchain
	cp -f $TERMUX_PKG_BUILDER_DIR/toolchain.gn.in $TERMUX_PKG_CACHEDIR/custom-toolchain/BUILD.gn
	sed -i "s|@HOST_CC@|/usr/bin/clang-14|g
			s|@HOST_CXX@|/usr/bin/clang++-14|g
			s|@HOST_LD@|/usr/bin/clang++-14|g
			s|@HOST_AR@|$(command -v llvm-ar)|g
			s|@HOST_NM@|$(command -v llvm-nm)|g
			s|@HOST_IS_CLANG@|true|g
			s|@HOST_USE_GOLD@|false|g
			s|@HOST_SYSROOT@|$_amd64_sysroot_path|g
			" $TERMUX_PKG_CACHEDIR/custom-toolchain/BUILD.gn
	sed -i "s|@V8_CC@|/usr/bin/clang-14|g
			s|@V8_CXX@|/usr/bin/clang++-14|g
			s|@V8_LD@|/usr/bin/clang++-14|g
			s|@V8_AR@|$(command -v llvm-ar)|g
			s|@V8_NM@|$(command -v llvm-nm)|g
			s|@V8_TOOLCHAIN_NAME@|$_v8_toolchain_name|g
			s|@V8_CURRENT_CPU@|$_v8_current_cpu|g
			s|@V8_V8_CURRENT_CPU@|$_target_cpu|g
			s|@V8_IS_CLANG@|true|g
			s|@V8_USE_GOLD@|false|g
			s|@V8_SYSROOT@|$_v8_sysroot_path|g
			" $TERMUX_PKG_CACHEDIR/custom-toolchain/BUILD.gn

	cd $TERMUX_PKG_SRCDIR/chromium/src
	mkdir -p $TERMUX_PKG_BUILDDIR/out/Release
	cat $_common_args_file > $TERMUX_PKG_BUILDDIR/out/Release/args.gn
	gn gen $TERMUX_PKG_BUILDDIR/out/Release --export-compile-commands
}

termux_step_make() {
	cd $TERMUX_PKG_SRCDIR
	(termux_setup_rust
	cargo build --jobs $TERMUX_PKG_MAKE_PROCESSES --target $CARGO_TARGET_NAME --release)

	cd $TERMUX_PKG_BUILDDIR
	ninja -C $TERMUX_PKG_BUILDDIR/out/Release headless:headless_shell
}

termux_step_make_install() {
	cd $TERMUX_PKG_BUILDDIR
	mkdir -p $TERMUX_PREFIX/lib/$TERMUX_PKG_NAME

	# Install the runtime library
	termux_setup_rust
	cp $TERMUX_PKG_SRCDIR/build/$CARGO_TARGET_NAME/release/*.so $TERMUX_PREFIX/lib/$TERMUX_PKG_NAME/

	# Install chromium-related files
	local normal_files=(
		# Binary files
		headless_shell
		chrome_crashpad_handler

		# Resource files
		headless_lib_data.pak
		headless_lib_strings.pak

		# V8 Snapshot data
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
	)

	cp "${normal_files[@]/#/out/Release/}" "$TERMUX_PREFIX/lib/$TERMUX_PKG_NAME/"

	cp -Rf out/Release/angledata $TERMUX_PREFIX/lib/$TERMUX_PKG_NAME/

	chmod +x $TERMUX_PREFIX/lib/$TERMUX_PKG_NAME/headless_shell

	# Install as the default binary
	ln -sfr $TERMUX_PREFIX/lib/$TERMUX_PKG_NAME/headless_shell $TERMUX_PREFIX/bin/carbonyl
}

termux_step_post_make_install() {
	# Remove the dummy files
	rm $TERMUX_PREFIX/lib/lib{{pthread,resolv,ffi_pic}.a,rt.so}
}

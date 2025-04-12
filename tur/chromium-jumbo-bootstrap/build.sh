TERMUX_PKG_HOMEPAGE=https://www.chromium.org/Home
TERMUX_PKG_DESCRIPTION="Chromium web browser (bootstrap step)"
TERMUX_PKG_LICENSE="BSD 3-Clause"
TERMUX_PKG_MAINTAINER="Chongyun Lee <uchkks@protonmail.com>"
_CHROMIUM_VERSION=122.0.6261.128
TERMUX_PKG_VERSION=$_CHROMIUM_VERSION
TERMUX_PKG_SRCURL=(https://commondatastorage.googleapis.com/chromium-browser-official/chromium-$_CHROMIUM_VERSION.tar.xz)
TERMUX_PKG_SHA256=(51757e7ecf5bb1db4881562d021547be5f8065e4f22a6ba9bf6e9a3a0d32c2ea)
TERMUX_PKG_DEPENDS="atk, cups, dbus, fontconfig, gtk3, krb5, libc++, libdrm, libevdev, libxkbcommon, libminizip, libnss, libwayland, libx11, mesa, openssl, pango, pulseaudio, zlib"
# TODO: Split chromium-common and chromium-headless
# TERMUX_PKG_DEPENDS+=", chromium-common"
# TERMUX_PKG_SUGGESTS="chromium-headless, chromium-driver"
# Chromium doesn't support i686 on Linux.
TERMUX_PKG_BLACKLISTED_ARCHES="i686"
TERMUX_PKG_NO_STRIP=true
TERMUX_PKG_NO_ELF_CLEANER=true

SYSTEM_LIBRARIES="    libdrm  fontconfig"
# TERMUX_PKG_DEPENDS="libdrm, fontconfig"

termux_step_post_get_source() {
	python3 build/linux/unbundle/replace_gn_files.py --system-libraries \
		$SYSTEM_LIBRARIES
}

termux_step_pre_configure() {
	# Certain packages are not safe to build on device because their
	# build.sh script deletes specific files in $TERMUX_PREFIX.
	if $TERMUX_ON_DEVICE_BUILD; then
		termux_error_exit "Package '$TERMUX_PKG_NAME' is not safe for on-device builds."
	fi
}

termux_step_configure() {
	cd $TERMUX_PKG_SRCDIR
	termux_setup_ninja

	# Fetch depot_tools
	export DEPOT_TOOLS_UPDATE=0
	if [ ! -f "$TERMUX_PKG_CACHEDIR/.depot_tools-fetched" ];then
		git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git $TERMUX_PKG_CACHEDIR/depot_tools
		touch "$TERMUX_PKG_CACHEDIR/.depot_tools-fetched"
	fi
	export PATH="$TERMUX_PKG_CACHEDIR/depot_tools:$PATH"

	################################################################
	# Please dont use these keys outside of Termux User Repository #
	# You can create your own at:                                  #
	# http://www.chromium.org/developers/how-tos/api-keys          #
	################################################################
	local _google_api_key _google_default_client_id _google_default_client_secret
	eval "$(base64 -d < $TERMUX_PKG_BUILDER_DIR/google-api-keys.base64enc)"

	# Remove termux's dummy pkg-config
	local _target_pkg_config=$(command -v pkg-config)
	local _host_pkg_config="$(cat $_target_pkg_config | grep exec | awk '{print $2}')"
	rm -rf $TERMUX_PKG_TMPDIR/host-pkg-config-bin
	mkdir -p $TERMUX_PKG_TMPDIR/host-pkg-config-bin
	ln -s $_host_pkg_config $TERMUX_PKG_TMPDIR/host-pkg-config-bin/pkg-config
	export PATH="$TERMUX_PKG_TMPDIR/host-pkg-config-bin:$PATH"

	# For qt build
	export PATH="$TERMUX_PREFIX/opt/qt/cross/bin:$PATH"

	# Install amd64 rootfs and deps
	env -i PATH="$PATH" sudo apt update
	env -i PATH="$PATH" sudo apt install lsb-release -yq
	# env -i PATH="$PATH" sudo apt install libfontconfig1 libffi7 -yq
	env -i PATH="$PATH" sudo apt install libfontconfig1 -yq
	env -i PATH="$PATH" sudo ./build/install-build-deps.sh --no-syms --no-arm --no-chromeos-fonts --no-nacl --no-prompt --unsupported
	build/linux/sysroot_scripts/install-sysroot.py --arch=amd64
	local _amd64_sysroot_path="$(pwd)/build/linux/$(ls build/linux | grep 'amd64-sysroot')"
	rm -rf "$_amd64_sysroot_path"
	build/linux/sysroot_scripts/install-sysroot.py --arch=amd64

	# Link to system tools required by the build
	ln -sf $(command -v java) third_party/jdk/current/bin/

	# Install nodejs
	if [ ! -f "third_party/node/linux/node-linux-x64/bin/node" ]; then
		./third_party/node/update_node_binaries
	fi

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
	# This is needed to build crashpad
	rm -rf $TERMUX_PREFIX/include/spawn.h
	# This is needed to build cups
	cp -Rf $TERMUX_PREFIX/bin/cups-config usr/bin/
	chmod +x usr/bin/cups-config
	popd

	# Construct args
	local _clang_base_path="/usr/lib/llvm-18"
	local _host_cc="$_clang_base_path/bin/clang"
	local _host_cxx="$_clang_base_path/bin/clang++"
	local _host_toolchain="$TERMUX_PKG_CACHEDIR/custom-toolchain:host"
	local _target_cpu _target_sysroot="$TERMUX_PKG_TMPDIR/sysroot"
	local _v8_toolchain_name _v8_current_cpu _v8_sysroot_path
	if [ "$TERMUX_ARCH" = "aarch64" ]; then
		_target_cpu="arm64"
		_v8_current_cpu="arm64"
		_v8_sysroot_path="$_amd64_sysroot_path"
		_v8_toolchain_name="host"
	elif [ "$TERMUX_ARCH" = "x86_64" ]; then
		_target_cpu="x64"
		_v8_current_cpu="x64"
		_v8_sysroot_path="$_amd64_sysroot_path"
		_v8_toolchain_name="host"
	elif [ "$TERMUX_ARCH" = "arm" ]; then
		# Install i386 rootfs and deps
		# env -i PATH="$PATH" sudo apt install libfontconfig1:i386 libffi7:i386 -yq
		env -i PATH="$PATH" sudo apt install libfontconfig1:i386 -yq
		env -i PATH="$PATH" sudo ./build/install-build-deps.sh --lib32 --no-syms --no-arm --no-chromeos-fonts --no-nacl --no-prompt --unsupported
		build/linux/sysroot_scripts/install-sysroot.py --arch=i386
		local _i386_sysroot_path="$(pwd)/build/linux/$(ls build/linux | grep 'i386-sysroot')"
		rm -rf "$_i386_sysroot_path"
		build/linux/sysroot_scripts/install-sysroot.py --arch=i386
		_target_cpu="arm"
		_v8_current_cpu="x86"
		_v8_sysroot_path="$_i386_sysroot_path"
		_v8_toolchain_name="clang_x86_v8_arm"
	fi

	local _common_args_file=$TERMUX_PKG_TMPDIR/common-args-file
	rm -f $_common_args_file
	touch $_common_args_file

	echo "
# Set google key to disable the warning slogan
# Please DO NOT USE THIS KEY OUTSIDE OF TUR!
google_api_key = \"$_google_api_key\"
google_default_client_id = \"$_google_default_client_id\"
google_default_client_secret = \"$_google_default_client_secret\"
# Do official build to decrease file size
is_official_build = true
is_debug = false
symbol_level = 0
# Use our custom toolchain
use_sysroot = false
target_cpu = \"$_target_cpu\"
target_rpath = \"$TERMUX_PREFIX/lib\"
target_sysroot = \"$_target_sysroot\"
clang_base_path = \"$_clang_base_path\"
custom_toolchain = \"//build/toolchain/linux/unbundle:default\"
host_toolchain = \"$TERMUX_PKG_CACHEDIR/custom-toolchain:host\"
v8_snapshot_toolchain = \"$TERMUX_PKG_CACHEDIR/custom-toolchain:$_v8_toolchain_name\"
clang_use_chrome_plugins = false
dcheck_always_on = false
chrome_pgo_phase = 0
treat_warnings_as_errors = false
# Use system libraries as little as possible
use_system_freetype = false
use_system_libdrm = true
use_system_libffi = true
use_custom_libcxx = false
use_allocator_shim = false
use_partition_alloc_as_malloc = false
enable_backup_ref_ptr_support = false
enable_pointer_compression_support = false
use_nss_certs = true
use_udev = false
use_ozone = true
ozone_auto_platforms = false
ozone_platform = \"x11\"
ozone_platform_x11 = true
ozone_platform_wayland = true
ozone_platform_headless = true
angle_enable_vulkan = true
angle_enable_swiftshader = true
angle_enable_abseil = false
# Use Chrome-branded ffmpeg for more codecs
is_component_ffmpeg = true
ffmpeg_branding = \"Chrome\"
proprietary_codecs = true
use_qt = false
use_libpci = false
use_alsa = false
use_pulseaudio = true
rtc_use_pipewire = false
use_vaapi = false
# See comments below
enable_nacl = false
# Host compiler (clang-13) doesn't support LTO well
is_cfi = false
use_cfi_icall = false
use_thin_lto = false
# Disable rust
enable_rust = false
llvm_android_mainline = true
# Enable jumbo build (unified build)
use_jumbo_build = true
" > $_common_args_file

	if [ "$TERMUX_ARCH" = "arm" ]; then
		echo "arm_arch = \"armv7-a\"" >> $_common_args_file
		echo "arm_float_abi = \"softfp\"" >> $_common_args_file
	fi

	# Use custom toolchain
	rm -rf $TERMUX_PKG_CACHEDIR/custom-toolchain
	mkdir -p $TERMUX_PKG_CACHEDIR/custom-toolchain
	cp -f $TERMUX_PKG_BUILDER_DIR/toolchain-template/host-toolchain.gn.in $TERMUX_PKG_CACHEDIR/custom-toolchain/BUILD.gn
	sed -i "s|@HOST_CC@|$_host_cc|g
			s|@HOST_CXX@|$_host_cxx|g
			s|@HOST_LD@|$_host_cxx|g
			s|@HOST_AR@|$(command -v llvm-ar)|g
			s|@HOST_NM@|$(command -v llvm-nm)|g
			s|@HOST_IS_CLANG@|true|g
			s|@HOST_USE_GOLD@|false|g
			s|@HOST_SYSROOT@|$_amd64_sysroot_path|g
			s|@V8_CURRENT_CPU@|$_target_cpu|g
			" $TERMUX_PKG_CACHEDIR/custom-toolchain/BUILD.gn
	if [ "$_v8_toolchain_name" != "host" ]; then
		cat $TERMUX_PKG_BUILDER_DIR/toolchain-template/v8-toolchain.gn.in >> $TERMUX_PKG_CACHEDIR/custom-toolchain/BUILD.gn
		sed -i "s|@V8_CC@|$_host_cc|g
				s|@V8_CXX@|$_host_cxx|g
				s|@V8_LD@|$_host_cxx|g
				s|@V8_AR@|$(command -v llvm-ar)|g
				s|@V8_NM@|$(command -v llvm-nm)|g
				s|@V8_TOOLCHAIN_NAME@|$_v8_toolchain_name|g
				s|@V8_CURRENT_CPU@|$_v8_current_cpu|g
				s|@V8_V8_CURRENT_CPU@|$_target_cpu|g
				s|@V8_IS_CLANG@|true|g
				s|@V8_USE_GOLD@|false|g
				s|@V8_SYSROOT@|$_v8_sysroot_path|g
				" $TERMUX_PKG_CACHEDIR/custom-toolchain/BUILD.gn
	fi

	# Patch for gcc
	patch -p1 -d $_amd64_sysroot_path < $TERMUX_PKG_BUILDER_DIR/sysroot-patches/libstdcxx3-10-lwg3545.diff
	patch -p1 -d $_amd64_sysroot_path < $TERMUX_PKG_BUILDER_DIR/sysroot-patches/libstdcxx3-10-optional-struct.diff
	if [ "$_v8_toolchain_name" != "host" ]; then
		patch -p1 -d $_v8_sysroot_path < $TERMUX_PKG_BUILDER_DIR/sysroot-patches/libstdcxx3-10-lwg3545.diff
		patch -p1 -d $_v8_sysroot_path < $TERMUX_PKG_BUILDER_DIR/sysroot-patches/libstdcxx3-10-optional-struct.diff
	fi

	mkdir -p $TERMUX_PKG_BUILDDIR/out/Release
	cat $_common_args_file > $TERMUX_PKG_BUILDDIR/out/Release/args.gn
	gn gen $TERMUX_PKG_BUILDDIR/out/Release --export-compile-commands

	export cr_v8_toolchain="$_v8_toolchain_name"
}

termux_step_make() {
	cd $TERMUX_PKG_BUILDDIR

	# Build v8 snapshot and tools
	time ninja -C out/Release \
						v8_context_snapshot \
						run_mksnapshot_default \
						run_torque \
						generate_bytecode_builtins_list \
						v8:run_gen-regexp-special-case

	# Build host tools
	time ninja -C out/Release \
						generate_top_domain_list_variables_file \
						generate_chrome_colors_info \
						character_data \
						gen_root_store_inc \
						generate_transport_security_state \
						generate_top_domains_trie

	# Build swiftshader
	time ninja -C out/Release \
						third_party/swiftshader/src/Vulkan:icd_file \
						third_party/swiftshader/src/Vulkan:swiftshader_libvulkan

	# (Maybe future?) Build ANGLE
	# time ninja -C out/Release \
	# 					third_party/angle:libEGL \
	# 					third_party/angle:libGLESv2 \
	# 					third_party/angle:angle_version_info \
	# 					third_party/angle:angle_gpu_info_util \
	# 					third_party/angle:translator \
	# 					third_party/angle:translator_gl_d3d_only \
	# 					third_party/angle:angle_image_util \
	# 					third_party/angle:includes
}

termux_step_make_install() {
	cd $TERMUX_PKG_BUILDDIR
	mkdir -p $TERMUX_PREFIX/opt/$TERMUX_PKG_NAME

	local v8_tools=(
		mksnapshot                       # run_mksnapshot_default
		torque                           # torque
		bytecode_builtins_list_generator # generate_bytecode_builtins_list
		gen-regexp-special-case          # v8:run_gen-regexp-special-case
	)
	cp "${v8_tools[@]/#/out/Release/$cr_v8_toolchain/}" "$TERMUX_PREFIX/opt/$TERMUX_PKG_NAME/"

	local host_tools=(
		make_top_domain_list_variables     # generate_top_domain_list_variables_file
		generate_colors_info               # generate_chrome_colors_info
		character_data_generator           # character_data
		root_store_tool                    # gen_root_store_inc
		transport_security_state_generator # generate_transport_security_state
		top_domain_generator               # generate_top_domains_trie
	)
	cp "${host_tools[@]/#/out/Release/host/}" "$TERMUX_PREFIX/opt/$TERMUX_PKG_NAME/"

	local normal_files=(
		# v8 snapshot data
		snapshot_blob.bin
		v8_context_snapshot.bin

		# swiftshader
		libvk_swiftshader.so
		vk_swiftshader_icd.json

		# ICU data
		icudtl.dat
	)
	cp "${normal_files[@]/#/out/Release/}" "$TERMUX_PREFIX/opt/$TERMUX_PKG_NAME/"
}

termux_step_post_make_install() {
	# Remove the dummy files
	rm $TERMUX_PREFIX/lib/lib{{pthread,resolv,ffi_pic}.a,rt.so}
}

TERMUX_PKG_HOMEPAGE=https://www.chromium.org/Home
TERMUX_PKG_DESCRIPTION="Chromium web browser"
TERMUX_PKG_LICENSE="BSD 3-Clause"
TERMUX_PKG_MAINTAINER="Chongyun Lee <uchkks@protonmail.com>"
_CHROMIUM_VERSION=125.0.6422.141
_TEST_COMMIT=4b1e83937122185343ba92e909b021f307c719ca
_TEST_COMMIT_POSITION=1287751
TERMUX_PKG_VERSION=$_CHROMIUM_VERSION-r$_TEST_COMMIT_POSITION
TERMUX_PKG_DEPENDS="atk, cups, dbus, gtk3, krb5, libc++, libxkbcommon, libminizip, libnss, libwayland, libx11, mesa, openssl, pango, pulseaudio, libdrm, libjpeg-turbo, libpng, libwebp, libflac, fontconfig, freetype, zlib, libxml2, libxslt, libopus, libsnappy"
# TODO: Split chromium-common and chromium-headless
# TERMUX_PKG_DEPENDS+=", chromium-common"
# TERMUX_PKG_SUGGESTS="chromium-headless, chromium-driver"
TERMUX_PKG_SUGGESTS="qt5-qtbase"
TERMUX_PKG_BUILD_DEPENDS="qt5-qtbase, qt5-qtbase-cross-tools"
# Chromium doesn't support i686 on Linux.
TERMUX_PKG_BLACKLISTED_ARCHES="i686"

TERMUX_PKG_BREAKS="chromium"
TERMUX_PKG_CONFLICTS="chromium"
TERMUX_PKG_PROVIDES="chromium"

SYSTEM_LIBRARIES="    libdrm  fontconfig"
# TERMUX_PKG_DEPENDS="libdrm, fontconfig"

__tur_chromium_is_mountpoint() {
	local path=$(readlink -f $1)
	if [ x"$path" = x"" ]; then
		return 1
	fi
	set +e
	grep -q "$path" /proc/mounts
	local result=$?
	set -e
	if [ "$result" = 0 ]; then
		return 0
	else
		return 1
	fi
}

__tur_chromium_sudo() {
	env -i PATH="$PATH" sudo "$@"
}

termux_step_get_source() {
	# Fetch depot_tools
	export DEPOT_TOOLS_UPDATE=0
	if [ ! -f "$TERMUX_PKG_CACHEDIR/.depot_tools-fetched" ]; then
		git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git $TERMUX_PKG_CACHEDIR/depot_tools
		touch "$TERMUX_PKG_CACHEDIR/.depot_tools-fetched"
	fi
	export PATH="$TERMUX_PKG_CACHEDIR/depot_tools:$PATH"

	# Fetch chromium source
	local __src_dir="$HOME/chromium-sources/chromium"
	if [ ! -f "$TERMUX_PKG_CACHEDIR/.chromium-source-fetched" ]; then
		mkdir -p "$__src_dir"
		pushd "$__src_dir"
		fetch --nohooks chromium || (
			cd src && git reset --hard && git checkout main && git pull &&
			_remote_main="$(git rev-parse origin/main)" && cd .. &&
			gclient sync -D --nohooks --verbose --revision src@$_remote_main &&
			gclient fetch --verbose
		)
		pushd src
		gclient runhooks
		popd # "$__src_dir/src"
		popd # "$__src_dir"
		touch "$TERMUX_PKG_CACHEDIR/.chromium-source-fetched"
	fi

	# umount layers
	local __layer1_dir="$HOME/chromium-layer-1"
	if __tur_chromium_is_mountpoint "$__layer1_dir/merged" ; then
		__tur_chromium_sudo umount "$__layer1_dir/merged"
	fi
	local __layer2_dir="$HOME/chromium-layer-2"
	if __tur_chromium_is_mountpoint "$__layer2_dir/merged" ; then
		__tur_chromium_sudo umount "$__layer2_dir/merged"
	fi
	local __layer3_dir="$HOME/chromium-layer-3"
	if __tur_chromium_is_mountpoint "$__layer3_dir/merged" ; then
		__tur_chromium_sudo umount "$__layer3_dir/merged"
	fi

	# Layer 1, contains the source code versioned $_CHROMIUM_VERSION
	mkdir -p "$__layer1_dir"
	pushd "$__layer1_dir"
	# __tur_chromium_sudo rm -rf merged/ upperdir/ workdir/
	mkdir -p merged/ upperdir/ workdir/
	__tur_chromium_sudo mount -t overlay -o lowerdir=$__src_dir,upperdir=$__layer1_dir/upperdir,workdir=$__layer1_dir/workdir overlay $__layer1_dir/merged
	# rm -rf "$__layer1_dir/merged/.cipd"
	popd # "$__layer1_dir"
	pushd "$__layer1_dir/merged"
	# gclient sync --revision src@$_CHROMIUM_VERSION --verbose --force
	popd # "$__layer1_dir/merged"

	# Layer 2, contains the source code of given commit
	mkdir -p "$__layer2_dir"
	pushd "$__layer2_dir"
	# __tur_chromium_sudo rm -rf merged/ upperdir/ workdir/
	mkdir -p merged/ upperdir/ workdir/
	__tur_chromium_sudo mount -t overlay -o lowerdir=$__layer1_dir/upperdir:$__src_dir,upperdir=$__layer2_dir/upperdir,workdir=$__layer2_dir/workdir overlay $__layer2_dir/merged
	# rm -rf "$__layer2_dir/merged/.cipd"
	popd # "$__layer2_dir"
	pushd "$__layer2_dir/merged"
	# gclient sync --revision src@$_TEST_COMMIT --verbose --force
	popd # "$__layer2_dir/merged"

	# Layer 3, the real work dir, waiting for patches
	mkdir -p "$__layer3_dir"
	pushd "$__layer3_dir"
	__tur_chromium_sudo rm -rf merged/ upperdir/ workdir/
	mkdir -p merged/ upperdir/ workdir/
	__tur_chromium_sudo mount -t overlay -o lowerdir=$__layer2_dir/upperdir:$__layer1_dir/upperdir:$__src_dir,upperdir=$__layer3_dir/upperdir,workdir=$__layer3_dir/workdir overlay $__layer3_dir/merged
	popd # "$__layer3_dir"

	# Now, we've get the real source of given commit, just provide the symlink
	rm -rf $$TERMUX_PKG_SRCDIR
	ln -sfr "$__layer3_dir/merged/src" $TERMUX_PKG_SRCDIR
}

termux_step_post_get_source() {
	python $TERMUX_SCRIPTDIR/common-files/apply-chromium-patches.py -v $_CHROMIUM_VERSION

	python3 build/linux/unbundle/replace_gn_files.py --system-libraries \
		$SYSTEM_LIBRARIES
	python3 third_party/libaddressinput/chromium/tools/update-strings.py
}

termux_step_configure() {
	cd $TERMUX_PKG_SRCDIR
	termux_setup_ninja
	termux_setup_nodejs

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
	rm -rf $TERMUX_PKG_CACHEDIR/host-pkg-config-bin
	mkdir -p $TERMUX_PKG_CACHEDIR/host-pkg-config-bin
	ln -s $_host_pkg_config $TERMUX_PKG_CACHEDIR/host-pkg-config-bin/pkg-config
	export PATH="$TERMUX_PKG_CACHEDIR/host-pkg-config-bin:$PATH"

	# For qt build
	export PATH="$TERMUX_PREFIX/opt/qt/cross/bin:$PATH"

	# Install amd64 rootfs and deps
	env -i PATH="$PATH" sudo apt update
	env -i PATH="$PATH" sudo apt install lsb-release -yq
	env -i PATH="$PATH" sudo apt install libfontconfig1 libffi7 -yq
	env -i PATH="$PATH" sudo ./build/install-build-deps.sh --no-syms --no-android --no-arm --no-chromeos-fonts --no-nacl --no-prompt
	build/linux/sysroot_scripts/install-sysroot.py --arch=amd64
	local _amd64_sysroot_path="$(pwd)/build/linux/$(ls build/linux | grep 'amd64-sysroot')"

	# Setup rust toolchain and clang toolchain
	./tools/rust/update_rust.py
	./tools/clang/scripts/update.py

	local CARGO_TARGET_NAME="${TERMUX_ARCH}-linux-android"
	if [[ "${TERMUX_ARCH}" == "arm" ]]; then
		CARGO_TARGET_NAME="armv7-linux-androideabi"
	fi

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
	if [ ! -d "$TERMUX_PKG_CACHEDIR/sysroot-$TERMUX_ARCH" ]; then
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
		# Cherry-pick LWG3545 for NDK r26
		# patch -p1 < $TERMUX_SCRIPTDIR/common-files/chromium-patches/sysroot-patches/libcxx-17-lwg3545.diff
		popd
		mv $TERMUX_PKG_TMPDIR/sysroot $TERMUX_PKG_CACHEDIR/sysroot-$TERMUX_ARCH
	fi

	# Construct args
	local _clang_base_path="$PWD/third_party/llvm-build/Release+Asserts"
	local _host_cc="$_clang_base_path/bin/clang"
	local _host_cxx="$_clang_base_path/bin/clang++"
	local _host_clang_version=$($_host_cc --version | grep -m1 version | sed -E 's|.*\bclang version ([0-9]+).*|\1|')
	local _target_cpu _target_sysroot="$TERMUX_PKG_CACHEDIR/sysroot-$TERMUX_ARCH"
	local _v8_toolchain_name _v8_current_cpu _v8_sysroot_path
	if [ "$TERMUX_ARCH" = "aarch64" ]; then
		_target_cpu="arm64"
		_v8_current_cpu="x64"
		_v8_sysroot_path="$_amd64_sysroot_path"
		_v8_toolchain_name="clang_x64_v8_arm64"
	elif [ "$TERMUX_ARCH" = "arm" ]; then
		# Install i386 rootfs and deps
		env -i PATH="$PATH" sudo apt install libfontconfig1:i386 libffi7:i386 -yq
		env -i PATH="$PATH" sudo ./build/install-build-deps.sh --lib32 --no-syms --no-android --no-arm --no-chromeos-fonts --no-nacl --no-prompt
		build/linux/sysroot_scripts/install-sysroot.py --arch=i386
		local _i386_sysroot_path="$(pwd)/build/linux/$(ls build/linux | grep 'i386-sysroot')"
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
# Set google key to disable the warning slogan
# Please DO NOT USE THIS KEY OUTSIDE OF TUR!
google_api_key = \"$_google_api_key\"
google_default_client_id = \"$_google_default_client_id\"
google_default_client_secret = \"$_google_default_client_secret\"
# Do official build to decrease file size
is_official_build = false
is_debug = true
is_component_build = false
symbol_level = 2
# Use our custom toolchain
clang_version = \"$_host_clang_version\"
use_sysroot = false
target_cpu = \"$_target_cpu\"
target_rpath = \"$TERMUX_PREFIX/lib\"
target_sysroot = \"$_target_sysroot\"
custom_toolchain = \"//build/toolchain/linux/unbundle:default\"
custom_toolchain_clang_base_path = \"$TERMUX_STANDALONE_TOOLCHAIN\"
custom_toolchain_clang_version = "18"
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
use_custom_libcxx_for_host = true
use_allocator_shim = false
use_partition_alloc_as_malloc = false
enable_backup_ref_ptr_slow_checks = false
enable_dangling_raw_ptr_checks = false
enable_dangling_raw_ptr_feature_flag = false
backup_ref_ptr_extra_oob_checks = false
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
use_qt = true
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
# Enable rust
custom_target_rust_abi_target = \"$CARGO_TARGET_NAME\"
llvm_android_mainline = true
" > $_common_args_file

	if [ "$TERMUX_ARCH" = "arm" ]; then
		echo "arm_arch = \"armv7-a\"" >> $_common_args_file
		echo "arm_float_abi = \"softfp\"" >> $_common_args_file
	fi

	# Use custom toolchain
	mkdir -p $TERMUX_PKG_CACHEDIR/custom-toolchain
	cp -f $TERMUX_PKG_BUILDER_DIR/toolchain.gn.in $TERMUX_PKG_CACHEDIR/custom-toolchain/BUILD.gn
	sed -i "s|@HOST_CC@|$_host_cc|g
			s|@HOST_CXX@|$_host_cxx|g
			s|@HOST_LD@|$_host_cxx|g
			s|@HOST_AR@|$(command -v llvm-ar)|g
			s|@HOST_NM@|$(command -v llvm-nm)|g
			s|@HOST_IS_CLANG@|true|g
			s|@HOST_USE_GOLD@|false|g
			s|@HOST_SYSROOT@|$_amd64_sysroot_path|g
			" $TERMUX_PKG_CACHEDIR/custom-toolchain/BUILD.gn
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

	# Generate ninja files
	mkdir -p $TERMUX_PKG_BUILDDIR/out/Release
	cat $_common_args_file > $TERMUX_PKG_BUILDDIR/out/Release/args.gn
	gn gen $TERMUX_PKG_BUILDDIR/out/Release
}

termux_step_make() {
	cd $TERMUX_PKG_BUILDDIR
	ninja -C out/Release chromedriver chrome chrome_crashpad_handler headless_shell -k 0 || bash
	rm -rf "$TERMUX_PKG_CACHEDIR/sysroot-$TERMUX_ARCH"
}

termux_step_make_install() {
	cd $TERMUX_PKG_BUILDDIR
	mkdir -p $TERMUX_PREFIX/opt/$TERMUX_PKG_NAME

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

		# FFmpeg
		libffmpeg.so

		# Qt
		libqt5_shim.so
	)

	cp "${normal_files[@]/#/out/Release/}" "$TERMUX_PREFIX/opt/$TERMUX_PKG_NAME/"

	cp -Rf out/Release/angledata $TERMUX_PREFIX/opt/$TERMUX_PKG_NAME/
	cp -Rf out/Release/locales $TERMUX_PREFIX/opt/$TERMUX_PKG_NAME/
	cp -Rf out/Release/MEIPreload $TERMUX_PREFIX/opt/$TERMUX_PKG_NAME/
	cp -Rf out/Release/resources $TERMUX_PREFIX/opt/$TERMUX_PKG_NAME/

	sed "s|@TERMUX_PREFIX@|$TERMUX_PREFIX|g" \
		$TERMUX_PKG_BUILDER_DIR/chromium-launcher.sh.in > $TERMUX_PREFIX/opt/$TERMUX_PKG_NAME/chromium-launcher.sh
	chmod +x $TERMUX_PREFIX/opt/$TERMUX_PKG_NAME/chromium-launcher.sh
}

termux_step_post_make_install() {
	# Remove the dummy files
	rm $TERMUX_PREFIX/lib/lib{{pthread,resolv,ffi_pic}.a,rt.so}
}

termux_step_post_massage() {
	# Except the deb file, we also create a zip file like chromium release
	mkdir -p $TERMUX_SCRIPTDIR/output-chromium

	pushd $TERMUX_PKG_MASSAGEDIR/$TERMUX_PREFIX/opt/$TERMUX_PKG_NAME
	zip -r $TERMUX_SCRIPTDIR/output-chromium/chromium-v$TERMUX_PKG_VERSION-linux-$TERMUX_ARCH.zip ./*
	popd
}

# TODO:
# (2) Split packages

# ######################### About system libraries ############################
# We only pick up a few libraries to let chromium link against. Others may
# contains 
# FYI, all the available libraries and whether they can be used for linking
# are listed below.
#
# Name in Chromium | libdrm libjpeg       libpng libwebp fontconfig libxslt
# Name in Termux   | libdrm libjpeg-turbo libpng libwebp fontconfig libxslt
#
# Name in Chromium | freetype libxml  opus    snappy    flac    zlib
# Name in Termux   | freetype libxml2 libopus libsnappy libflac zlib
#
# These libraries cannot be used as system libraries, because Chromium-provided
# debian rootfs doesn't have them (or their headers). Maybe we should construct
# our own rootfs later.
# Name in Chromium | harfbuzz-ng  dav1d ffmpeg libaom libjxl libvpx libevent double-conversion jsoncpp
# Name in Termux   | harfbuzz  libdav1d ffmpeg libaom libjxl libvpx libevent double-conversion jsoncpp
#
# These libraries cannot be used due to configuation errors like
# `error: '/usr/bin/brotli', needed by 'clang_x64/brotli', missing and no known rule to make it`/
# Name in Chromium | brotli    icu    re2
# Name in Termux   | brotli libicu libre2
#
# These libraries cannot be used because they don't exist in Termux.
# Name in Chromium | absl* crc32c, libavif, libXNVCtrl, libyuv, openh264, libSPIRV-Tools
#
# TODO: link against system ffmpeg
# #############################################################################

# ######################### About Native Client ###############################
# When set `enable_nacl = true`, the following error occurs.
# ninja: error: 'native_client/toolchain/linux_x86/pnacl_newlib/bin/arm-nacl-objcopy', needed by 'nacl_irt_arm.nexe', missing and no known rule to make it.
# If we want to enable NaCi, maybe we should build the toolchain of NaCl too.
# But I don't think this is necessary. NaCl existing or not will take little 
# influence on Chromium. So I'd like to disable NaCl.
# #############################################################################

# ############################ About Sandbox ##################################
# First, setuid-sandbox is never usable on Termux, beacuse setuid syscall is
# disabled by Android's SELinux. Second, lots of patches are needed to let
# seccomp-bpf sandbox work properly on Android. I've tried many times but I
# can't make it. If your are willing to work on this, feel free to submit a PR.
# #############################################################################

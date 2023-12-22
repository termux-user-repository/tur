TERMUX_PKG_HOMEPAGE=https://www.chromium.org/Home
TERMUX_PKG_DESCRIPTION="Chromium web browser"
TERMUX_PKG_LICENSE="BSD 3-Clause"
TERMUX_PKG_MAINTAINER="Chongyun Lee <uchkks@protonmail.com>"
_CHROMIUM_VERSION=120.0.6099.129
TERMUX_PKG_VERSION=$_CHROMIUM_VERSION
TERMUX_PKG_SRCURL=(https://commondatastorage.googleapis.com/chromium-browser-official/chromium-$_CHROMIUM_VERSION.tar.xz)
TERMUX_PKG_SHA256=(be36d5abecfafdc68d9b27b0bee65136316610a295e844b99483a7520b245f85)
TERMUX_PKG_DEPENDS="atk, cups, dbus, gtk3, krb5, libc++, libevdev, libxkbcommon, libminizip, libnss, libwayland, libx11, mesa, openssl, pango, pulseaudio, libdrm, libjpeg-turbo, libpng, libwebp, libflac, fontconfig, freetype, zlib, libxml2, libxslt, libopus, libsnappy"
# TODO: Split chromium-common and chromium-headless
# TERMUX_PKG_DEPENDS+=", chromium-common"
# TERMUX_PKG_SUGGESTS="chromium-headless, chromium-driver"
TERMUX_PKG_SUGGESTS="qt5-qtbase"
TERMUX_PKG_BUILD_DEPENDS="qt5-qtbase, qt5-qtbase-cross-tools"
# Chromium doesn't support i686 on Linux.
TERMUX_PKG_BLACKLISTED_ARCHES="i686"

SYSTEM_LIBRARIES="    libdrm  fontconfig"
# TERMUX_PKG_DEPENDS="libdrm, fontconfig"

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
	rm -rf $TERMUX_PKG_TMPDIR/host-pkg-config-bin
	mkdir -p $TERMUX_PKG_TMPDIR/host-pkg-config-bin
	ln -s $_host_pkg_config $TERMUX_PKG_TMPDIR/host-pkg-config-bin/pkg-config
	export PATH="$TERMUX_PKG_TMPDIR/host-pkg-config-bin:$PATH"

	# For qt build
	export PATH="$TERMUX_PREFIX/opt/qt/cross/bin:$PATH"

	# Install amd64 rootfs and deps
	env -i PATH="$PATH" sudo apt update
	env -i PATH="$PATH" sudo apt install lsb-release -yq
	env -i PATH="$PATH" sudo apt install libfontconfig1 libffi7 -yq
	env -i PATH="$PATH" sudo ./build/install-build-deps.sh --no-syms --no-android --no-arm --no-chromeos-fonts --no-nacl --no-prompt
	build/linux/sysroot_scripts/install-sysroot.py --arch=amd64
	local _amd64_sysroot_path="$(pwd)/build/linux/$(ls build/linux | grep 'amd64-sysroot')"

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
	# This is needed to build crashpad
	rm -rf $TERMUX_PREFIX/include/spawn.h
	# This is needed to build cups
	cp -Rf $TERMUX_PREFIX/bin/cups-config usr/bin/
	chmod +x usr/bin/cups-config
	popd

	# Construct args
	local _clang_base_path="/usr/lib/llvm-15"
	local _host_cc="$_clang_base_path/bin/clang"
	local _host_cxx="$_clang_base_path/bin/clang++"
	local _target_cpu _target_sysroot="$TERMUX_PKG_TMPDIR/sysroot"
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
use_qt = true
use_libpci = false
use_alsa = false
use_pulseaudio = true
rtc_use_pipewire = false
use_vaapi_x11 = false
# See comments below
enable_nacl = false
# Host compiler (clang-13) doesn't support LTO well
is_cfi = false
use_cfi_icall = false
use_thin_lto = false
# Disable rust
enable_rust = false
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

	mkdir -p $TERMUX_PKG_BUILDDIR/out/Release
	cat $_common_args_file > $TERMUX_PKG_BUILDDIR/out/Release/args.gn
	gn gen $TERMUX_PKG_BUILDDIR/out/Release --export-compile-commands || bash
}

termux_step_make() {
	cd $TERMUX_PKG_BUILDDIR
	ninja -C out/Release chromedriver chrome chrome_crashpad_handler headless_shell -k 0 || bash
}

termux_step_make_install() {
	cd $TERMUX_PKG_BUILDDIR
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

		# FFmpeg
		libffmpeg.so

		# Qt
		libqt5_shim.so
	)

	cp "${normal_files[@]/#/out/Release/}" "$TERMUX_PREFIX/lib/chromium/"

	cp -Rf out/Release/angledata $TERMUX_PREFIX/lib/chromium/
	cp -Rf out/Release/locales $TERMUX_PREFIX/lib/chromium/
	cp -Rf out/Release/MEIPreload $TERMUX_PREFIX/lib/chromium/
	cp -Rf out/Release/resources $TERMUX_PREFIX/lib/chromium/

	sed "s|@TERMUX_PREFIX@|$TERMUX_PREFIX|g" \
		$TERMUX_PKG_BUILDER_DIR/chromium-launcher.sh.in > $TERMUX_PREFIX/lib/chromium/chromium-launcher.sh
	chmod +x $TERMUX_PREFIX/lib/chromium/chromium-launcher.sh

	ln -sfr $TERMUX_PREFIX/lib/chromium/chromium-launcher.sh $TERMUX_PREFIX/bin/chromium-browser
	ln -sfr $TERMUX_PREFIX/lib/chromium/chromedriver $TERMUX_PREFIX/bin/
	ln -sfr $TERMUX_PREFIX/lib/chromium/headless_shell $TERMUX_PREFIX/bin/

	# Install man pages and desktop files
	install -Dm644 $TERMUX_PKG_SRCDIR/chrome/app/resources/manpage.1.in \
		"$TERMUX_PREFIX/share/man/man1/chromium.1"
	install -Dm644 $TERMUX_PKG_SRCDIR/chrome/installer/linux/common/desktop.template \
		"$TERMUX_PREFIX/share/applications/chromium.desktop"
	sed -i \
		-e 's/@@MENUNAME@@/Chromium/g' \
		-e 's/@@PACKAGE@@/chromium/g' \
		-e 's/@@USR_BIN_SYMLINK_NAME@@/chromium-browser/g' \
		-e "s|Exec=/usr/bin|Exec=$TERMUX_PREFIX/bin|g" \
		"$TERMUX_PREFIX/share/applications/chromium.desktop" \
		"$TERMUX_PREFIX/share/man/man1/chromium.1"

	# Install logos
	for size in 24 48 64 128 256; do
		install -Dm644 "$TERMUX_PKG_SRCDIR/chrome/app/theme/chromium/product_logo_$size.png" \
			"$TERMUX_PREFIX/share/icons/hicolor/${size}x${size}/apps/chromium.png"
	done

	for size in 16 32; do
		install -Dm644 "$TERMUX_PKG_SRCDIR/chrome/app/theme/default_100_percent/chromium/product_logo_$size.png" \
			"$TERMUX_PREFIX/share/icons/hicolor/${size}x${size}/apps/chromium.png"
	done

	# Install AppStream metadata file
	install -Dm644 $TERMUX_PKG_SRCDIR/chrome/installer/linux/common/chromium-browser/chromium-browser.appdata.xml \
		"$TERMUX_PREFIX/share/metainfo/chromium.appdata.xml"
	sed -ni \
		-e 's/chromium-browser\.desktop/chromium.desktop/' \
		-e '/<update_contact>/d' \
		-e '/<p>/N;/<p>\n.*\(We invite\|Chromium supports Vorbis\)/,/<\/p>/d' \
		-e '/^<?xml/,$p' \
		"$TERMUX_PREFIX/share/metainfo/chromium.appdata.xml"
}

termux_step_post_make_install() {
	# Remove the dummy files
	rm $TERMUX_PREFIX/lib/lib{{pthread,resolv,ffi_pic}.a,rt.so}
}

# TODO:
# (2) Split packages

# ######################### About system libraries ############################
# We only pick up a few libraries to let chromium link against. Others may
# contain linking error due to the version mismatch between Google-provided
# sysroot and Termux.
# Name in Chromium | libdrm fontconfig
# Name in Termux   | libdrm fontconfig
#
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

TERMUX_PKG_HOMEPAGE=https://bitbucket.org/chromiumembedded/cef
TERMUX_PKG_DESCRIPTION="Chromium Embedded Framework (Used by brow6el)"
TERMUX_PKG_LICENSE="BSD 3-Clause"
TERMUX_PKG_MAINTAINER="@licy183"
TERMUX_PKG_VERSION="143.0.14+gdd46a37+chromium-143.0.7499.193"
_LIBCEF_COMMIT=$(echo $TERMUX_PKG_VERSION | cut -d'+' -f 2)
_LIBCEF_COMMIT=${_LIBCEF_COMMIT:1}
_CHROMIUM_VERSION=$(echo $TERMUX_PKG_VERSION | cut -d'+' -f 3 | cut -d'-' -f 2)
TERMUX_PKG_SRCURL=https://commondatastorage.googleapis.com/chromium-browser-official/chromium-$_CHROMIUM_VERSION-lite.tar.xz
TERMUX_PKG_SHA256=402961efc1ee279d23bc6e3a3caf01ee3ed230ca97ac339ba340f84f7cec9d9f
TERMUX_PKG_DEPENDS="atk, cups, dbus, fontconfig, gtk3, krb5, libc++, libevdev, libxkbcommon, libminizip, libnss, libx11, mesa, openssl, pango, pulseaudio, zlib"
TERMUX_PKG_BUILD_DEPENDS="libcef-host-tools-for-brow6el, libffi-static"
# TODO: Split chromium-common and chromium-headless
# TERMUX_PKG_DEPENDS+=", chromium-common"
# TERMUX_PKG_SUGGESTS="chromium-headless, chromium-driver"
# Chromium doesn't support i686 on Linux.
TERMUX_PKG_EXCLUDED_ARCHES="i686"
TERMUX_PKG_ON_DEVICE_BUILD_NOT_SUPPORTED=true
TERMUX_PKG_AUTO_UPDATE=false

SYSTEM_LIBRARIES="    fontconfig"
# TERMUX_PKG_DEPENDS="fontconfig"

termux_pkg_auto_update() {
	local latest_version="$(. $TERMUX_SCRIPTDIR/x11-packages/libcef-host-tools-for-brow6el/build.sh; echo ${TERMUX_PKG_VERSION})"

	if ! termux_pkg_is_update_needed \
		"${TERMUX_PKG_VERSION#*:}" "${latest_version}"; then
		echo "INFO: No update needed. Already at version '${latest_version}'."
		return 0
	fi

	local tmpdir="$(mktemp -d)"
	curl -sLo "${tmpdir}/tmpfile" "https://commondatastorage.googleapis.com/chromium-browser-official/chromium-$latest_version-lite.tar.xz"
	local sha="$(sha256sum "${tmpdir}/tmpfile" | cut -d ' ' -f 1)"
	rm -fr "${tmpdir}"
	printf '%s\n' 'INFO: Generated checksums:' "${sha}"

	local e=0
	local uptime_now=$(cat /proc/uptime)
	local uptime_s="${uptime_now//.*}"
	local uptime_h_limit=1
	local uptime_s_limit=$((uptime_h_limit*60*60))
	[[ -z "${uptime_s}" ]] && [[ "$(uname -o)" != "Android" ]] && e=1
	[[ "${uptime_s}" == 0 ]] && [[ "$(uname -o)" != "Android" ]] && e=1
	[[ "${uptime_s}" -gt "${uptime_s_limit}" ]] && e=1

	if [[ "${e}" != 0 ]]; then
		cat <<- EOL >&2
		WARN: Auto update failure!
		latest_version=${latest_version}
		uptime_now=${uptime_now}
		uptime_s=${uptime_s}
		uptime_s_limit=${uptime_s_limit}
		EOL
		return
	fi

	termux_pkg_upgrade_version "${latest_version}"
}

termux_step_post_get_source() {
	# Version guard
	local version_tools=$(. $TERMUX_SCRIPTDIR/x11-packages/libcef-host-tools-for-brow6el/build.sh; echo ${TERMUX_PKG_VERSION})
	if [ "${version_tools}" != "${TERMUX_PKG_VERSION}" ]; then
		termux_error_exit "Version mismatch between libcef-host-tools-for-brow6el and libcef-for-brow6el."
	fi

	# Clone the source code of libcef
	git clone https://bitbucket.org/chromiumembedded/cef

	# Install clang toolchain
	./tools/clang/scripts/update.py

	pushd cef
	# Checkout commit
	git checkout $_LIBCEF_COMMIT

	# Apply libcef's patches
	python3 tools/version_manager.py -u --fast-check
	python3 tools/patcher.py
	popd # cef

	# Apply patches related to chromium
	local f
	for f in $(find "$TERMUX_PKG_BUILDER_DIR/../libcef-host-tools-for-brow6el/cr-patches" -maxdepth 1 -type f -name *.patch | sort); do
		echo "Applying patch: $(basename $f)"
		patch -p1 --silent < "$f"
	done

	# Apply patches related to chromium
	local f
	for f in $(find "$TERMUX_PKG_BUILDER_DIR/../libcef-host-tools-for-brow6el/libcef-patches" -maxdepth 1 -type f -name *.patch | sort); do
		echo "Applying patch: $(basename $f)"
		patch -p1 --silent < "$f"
	done

	# Apply patches for jumbo build
	local f
	for f in $(find "$TERMUX_PKG_BUILDER_DIR/../libcef-host-tools-for-brow6el/jumbo-patches" -maxdepth 1 -type f -name *.patch | sort); do
		echo "Applying patch: $(basename $f)"
		patch -p1 --silent < "$f"
	done

	# Use some system libs
	python3 build/linux/unbundle/replace_gn_files.py --system-libraries \
		$SYSTEM_LIBRARIES

	# Remove the source file to keep more space
	# rm -f "$TERMUX_PKG_CACHEDIR/chromium-$TERMUX_PKG_VERSION-lite.tar.xz"
}

termux_step_pre_configure() {
	# Use prebuilt swiftshader
	mv $TERMUX_PKG_SRCDIR/third_party/swiftshader $TERMUX_PKG_SRCDIR/third_party/swiftshader.unused
	mkdir -p $TERMUX_PKG_SRCDIR/third_party/swiftshader/
	cp -Rf $TERMUX_PKG_BUILDER_DIR/third_party_override/swiftshader/* $TERMUX_PKG_SRCDIR/third_party/swiftshader/
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
	$TERMUX_PKG_CACHEDIR/depot_tools/ensure_bootstrap

	# Write gpu/webgpu/dawn_commit_hash.h
	if [ ! -f "$TERMUX_PKG_SRCDIR/gpu/webgpu/dawn_commit_hash.h" ]; then
		cat << EOF > $TERMUX_PKG_SRCDIR/gpu/webgpu/dawn_commit_hash.h
/* Generated by lastchange.py, do not edit.*/

#ifndef GPU_WEBGPU_DAWN_COMMIT_HASH_H_
#define GPU_WEBGPU_DAWN_COMMIT_HASH_H_

#define DAWN_COMMIT_HASH "$(cat $TERMUX_PKG_SRCDIR/gpu/webgpu/DAWN_VERSION)"

#endif  // GPU_WEBGPU_DAWN_COMMIT_HASH_H_
EOF
	fi

	# Remove termux's dummy pkg-config
	rm -rf $TERMUX_PKG_CACHEDIR/host-pkg-config-bin
	mkdir -p $TERMUX_PKG_CACHEDIR/host-pkg-config-bin
	ln -s /usr/bin/pkg-config "$TERMUX_PKG_CACHEDIR"/host-pkg-config-bin/pkg-config
	export PATH="$TERMUX_PKG_CACHEDIR/host-pkg-config-bin:$PATH"

	# Install amd64 rootfs
	build/linux/sysroot_scripts/install-sysroot.py --arch=amd64
	local _amd64_sysroot_path="$(pwd)/build/linux/$(ls build/linux | grep 'amd64-sysroot')"

	# Setup rust toolchain and clang toolchain
	./tools/rust/update_rust.py
	./tools/clang/scripts/update.py

	# Link to system tools required by the build
	ln -sf $(command -v java) third_party/jdk/current/bin/

	# Download test_fonts
	if [ ! -f "third_party/test_fonts/test_fonts.tar.gz" ]; then
		local _fonts_object_name=$(python -c "Var = str
Str = str
exec(open('$TERMUX_PKG_SRCDIR/DEPS').read())
print(deps['src/third_party/test_fonts/test_fonts']['objects'][0]['object_name'])
")
		local _fonts_sha256sum=$(python -c "Var = str
Str = str
exec(open('$TERMUX_PKG_SRCDIR/DEPS').read())
print(deps['src/third_party/test_fonts/test_fonts']['objects'][0]['sha256sum'])
")
		local _fonts_file="$TERMUX_PKG_SRCDIR/third_party/test_fonts/test_fonts.tar.gz"
		termux_download \
			"https://commondatastorage.googleapis.com/chromium-fonts/$_fonts_object_name" \
			"${_fonts_file}" \
			"${_fonts_sha256sum}"
		rm -rf third_party/test_fonts/test_fonts
		mkdir -p $TERMUX_PKG_SRCDIR/third_party/test_fonts/test_fonts-tmp
		tar -xf "$_fonts_file" -C "$TERMUX_PKG_SRCDIR/third_party/test_fonts/test_fonts-tmp"
		mv "$TERMUX_PKG_SRCDIR/third_party/test_fonts/test_fonts-tmp" "$TERMUX_PKG_SRCDIR/third_party/test_fonts/test_fonts"
	fi

	# Install nodejs
	if [ ! -f "third_party/node/linux/node-linux-x64/bin/node" ]; then
		./third_party/node/update_node_binaries
	fi

	local CARGO_TARGET_NAME="${TERMUX_ARCH}-linux-android"
	if [[ "${TERMUX_ARCH}" == "arm" ]]; then
		CARGO_TARGET_NAME="armv7-linux-androideabi"
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
		# This is needed to build cups
		cp -Rf $TERMUX_PREFIX/bin/cups-config usr/bin/
		chmod +x usr/bin/cups-config
		popd
		mv $TERMUX_PKG_TMPDIR/sysroot $TERMUX_PKG_CACHEDIR/sysroot-$TERMUX_ARCH
	fi

	# Construct args
	local _distrib_suffix=""
	local _clang_base_path="$PWD/third_party/llvm-build/Release+Asserts"
	local _host_cc="$_clang_base_path/bin/clang"
	local _host_cxx="$_clang_base_path/bin/clang++"
	local _host_clang_version=$($_host_cc --version | grep -m1 version | sed -E 's|.*\bclang version ([0-9]+).*|\1|')
	local _target_clang_base_path="$TERMUX_STANDALONE_TOOLCHAIN"
	local _target_cc="$_target_clang_base_path/bin/clang"
	local _target_clang_version=$($_target_cc --version | grep -m1 version | sed -E 's|.*\bclang version ([0-9]+).*|\1|')
	local _target_cpu _target_sysroot="$TERMUX_PKG_CACHEDIR/sysroot-$TERMUX_ARCH"
	local _v8_toolchain_name _v8_current_cpu _v8_sysroot_path
	if [ "$TERMUX_ARCH" = "aarch64" ]; then
		_target_cpu="arm64"
		_v8_current_cpu="arm64"
		_v8_sysroot_path="$_amd64_sysroot_path"
		_v8_toolchain_name="host"
		_distrib_suffix="_GN_arm64"
	elif [ "$TERMUX_ARCH" = "arm" ]; then
		# Install i386 rootfs
		build/linux/sysroot_scripts/install-sysroot.py --arch=i386
		local _i386_sysroot_path="$(pwd)/build/linux/$(ls build/linux | grep 'i386-sysroot')"
		_target_cpu="arm"
		_v8_current_cpu="x86"
		_v8_sysroot_path="$_i386_sysroot_path"
		_v8_toolchain_name="clang_x86_v8_arm"
		_distrib_suffix="_GN_arm"
	elif [ "$TERMUX_ARCH" = "x86_64" ]; then
		_target_cpu="x64"
		_v8_current_cpu="x64"
		_v8_sysroot_path="$_amd64_sysroot_path"
		_v8_toolchain_name="host"
		_distrib_suffix="_GN_x64"
	fi

	local _common_args_file=$TERMUX_PKG_TMPDIR/common-args-file
	rm -f $_common_args_file
	touch $_common_args_file

	echo "
# Do official build to decrease file size
is_official_build = true
is_debug = false
symbol_level = 0
# Use our custom toolchain
clang_version = \"$_host_clang_version\"
use_sysroot = false
target_cpu = \"$_target_cpu\"
target_rpath = \"$TERMUX_PREFIX/lib\"
target_sysroot = \"$_target_sysroot\"
custom_toolchain = \"//build/toolchain/linux/unbundle:default\"
custom_toolchain_clang_base_path = \"$_target_clang_base_path\"
custom_toolchain_clang_version = \"$_target_clang_version\"
host_toolchain = \"$TERMUX_PKG_CACHEDIR/custom-toolchain:host\"
v8_snapshot_toolchain = \"$TERMUX_PKG_CACHEDIR/custom-toolchain:$_v8_toolchain_name\"
clang_use_chrome_plugins = false
dcheck_always_on = false
chrome_pgo_phase = 0
treat_warnings_as_errors = false
# Use system libraries as little as possible
use_system_freetype = false
use_custom_libcxx = false
use_custom_libcxx_for_host = true
use_clang_modules = false
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
# TODO: Enable wayland
ozone_platform_wayland = false
ozone_platform_headless = true
angle_enable_vulkan = true
angle_enable_swiftshader = true
angle_enable_abseil = false
# Use Chrome-branded ffmpeg for more codecs
is_component_ffmpeg = true
ffmpeg_branding = \"Chrome\"
proprietary_codecs = true
use_qt5 = false
use_qt6 = false
use_libpci = false
use_alsa = false
use_pulseaudio = true
rtc_use_pipewire = false
use_vaapi = false
# Host compiler (clang-13) doesn't support LTO well
is_cfi = false
use_cfi_icall = false
use_thin_lto = false
# OpenCL doesn't work out of box in Termux, use NNAPI instead
build_tflite_with_opencl = false
build_tflite_with_nnapi = true
# Necessary for libcef
enable_widevine = true
bundle_widevine_cdm = false
# Enable rust
custom_target_rust_abi_target = \"$CARGO_TARGET_NAME\"
clang_warning_suppression_file = \"\"
exclude_unwind_tables = false
# Enable jumbo build (unified build)
use_jumbo_build = true
# Compile pdfium as a static library
pdf_is_complete_lib = true
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
				s|@V8_SYSROOT@|$_v8_sysroot_path|g
				" $TERMUX_PKG_CACHEDIR/custom-toolchain/BUILD.gn
	fi

	# Generate ninja files
	mkdir -p $TERMUX_PKG_BUILDDIR/out/Release${_distrib_suffix}
	cat $_common_args_file > $TERMUX_PKG_BUILDDIR/out/Release${_distrib_suffix}/args.gn
	gn gen $TERMUX_PKG_BUILDDIR/out/Release${_distrib_suffix}

	export cr_v8_toolchain="$_v8_toolchain_name"
	export libcef_distrib_suffix="$_distrib_suffix"
	export libcef_target_cpu="$_target_cpu"
}

termux_step_make() {
	cd $TERMUX_PKG_BUILDDIR

	# Build v8 snapshot and tools
	time ninja -C out/Release${libcef_distrib_suffix} \
						v8_context_snapshot \
						run_mksnapshot_default \
						run_torque \
						generate_bytecode_builtins_list \
						v8:run_gen-regexp-special-case

	# Build host tools
	time ninja -C out/Release${libcef_distrib_suffix} \
						generate_top_domain_list_variables_file \
						generate_chrome_colors_info \
						character_data \
						gen_root_store_inc \
						generate_transport_security_state \
						generate_top_domains_trie

	# Build swiftshader
	time ninja -C out/Release${libcef_distrib_suffix} \
						third_party/swiftshader/src/Vulkan:icd_file \
						third_party/swiftshader/src/Vulkan:swiftshader_libvulkan

	# Build pdfium
	time ninja -C out/Release${libcef_distrib_suffix} \
						third_party/pdfium \
						third_party/pdfium:pdfium_public_headers

	# Build other components
	ninja -C out/Release${libcef_distrib_suffix} cefsimple cefclient chrome_sandbox
}

termux_step_make_install() {
	cd $TERMUX_PKG_BUILDDIR

	# Run script to gather files
	ln -sfr $TERMUX_PKG_BUILDDIR/out $TERMUX_PKG_SRCDIR/out
	python \
		$TERMUX_PKG_SRCDIR/cef/tools/make_distrib.py \
			--output-dir $TERMUX_PKG_BUILDDIR/dist \
			--${libcef_target_cpu}-build --ninja-build --client --no-archive
	python \
		$TERMUX_PKG_SRCDIR/cef/tools/make_distrib.py \
			--output-dir $TERMUX_PKG_BUILDDIR/dist \
			--${libcef_target_cpu}-build --ninja-build --minimal --no-archive

	local _dist_suffix
	_dist_suffix="$libcef_target_cpu"
	if [ "$libcef_target_cpu" = "x64" ]; then
		_dist_suffix="64"
	fi

	# Install all the client files
	local _dist_dir_client _install_prefix_client
	_dist_dir_client="$TERMUX_PKG_BUILDDIR/dist/cef_binary_${TERMUX_PKG_VERSION}_linux${_dist_suffix}_client"
	_install_prefix_client="$TERMUX_PREFIX/opt/$TERMUX_PKG_NAME"
	rm -rf "$_install_prefix_client"
	mkdir -p "$_install_prefix_client"
	cp -Rfv $_dist_dir_client/* $_install_prefix_client/
	rm -rf $_dist_dir_client/

	# Install all the dev files, symlink to save space
	local _dist_dir_dev _install_prefix_dev
	_dist_dir_dev="$TERMUX_PKG_BUILDDIR/dist/cef_binary_${TERMUX_PKG_VERSION}_linux${_dist_suffix}_minimal"
	_install_prefix_dev="$TERMUX_PREFIX/opt/$TERMUX_PKG_NAME-dev"
	rm -rf "$_install_prefix_dev"
	mkdir -p "$_install_prefix_dev"
	cp -Rfv $_dist_dir_dev/* $_install_prefix_dev/
	local _file _filename _filefrom _fileto
	rm -rf $_install_prefix_dev/Release/*
	for _file in $_dist_dir_dev/Release/*; do
		_filename="$(basename $_file)"
		_filefrom="$_install_prefix_client/Release/$_filename"
		_fileto="$_install_prefix_dev/Release/$_filename"
		if [ ! -e "$_filefrom" ]; then
			termux_error_exit "$_filefrom not found."
		fi
		ln -sv "$_filefrom" "$_fileto"
	done
	rm -rf $_install_prefix_dev/Resources/*
	for _file in $_dist_dir_dev/Resources/*; do
		echo "$_file"
		_filename="$(basename $_file)"
		_filefrom="$_install_prefix_client/Release/$_filename"
		_fileto="$_install_prefix_dev/Resources/$_filename"
		if [ ! -e "$_filefrom" ]; then
			termux_error_exit "$_filefrom not found."
		fi
		ln -sv "$_filefrom" "$_fileto"
	done
	rm -rf $_dist_dir_dev/
}

termux_step_post_make_install() {
	# Remove the dummy files
	rm $TERMUX_PREFIX/lib/lib{{pthread,resolv,ffi_pic}.a,rt.so}
}

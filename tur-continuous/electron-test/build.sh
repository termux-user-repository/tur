TERMUX_PKG_HOMEPAGE=https://github.com/electron/electron
TERMUX_PKG_DESCRIPTION="Build cross-platform desktop apps with JavaScript, HTML, and CSS"
TERMUX_PKG_LICENSE="MIT, BSD 3-Clause"
TERMUX_PKG_MAINTAINER="Chongyun Lee <uchkks@protonmail.com>"
_CHROMIUM_VERSION=128.0.6613.186
TERMUX_PKG_VERSION=32.2.1
TERMUX_PKG_SRCURL=git+https://github.com/electron/electron
TERMUX_PKG_DEPENDS="atk, cups, dbus, fontconfig, gtk3, krb5, libc++, libdrm, libevdev, libxkbcommon, libminizip, libnss, libwayland, libx11, mesa, openssl, pango, pulseaudio, zlib"
TERMUX_PKG_BUILD_DEPENDS="libnotify, libffi-static"
# Chromium doesn't support i686 on Linux.
TERMUX_PKG_EXCLUDED_ARCHES="i686"

TERMUX_PKG_BREAKS="electron"
TERMUX_PKG_CONFLICTS="electron"
TERMUX_PKG_PROVIDES="electron"

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

__tur_setup_depot_tools() {
	export DEPOT_TOOLS_UPDATE=0
	if [ ! -f "$TERMUX_PKG_CACHEDIR/.depot_tools-fetched" ];then
		git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git $TERMUX_PKG_CACHEDIR/depot_tools
		touch "$TERMUX_PKG_CACHEDIR/.depot_tools-fetched"
	fi
	export PATH="$TERMUX_PKG_CACHEDIR/depot_tools:$PATH"
	export CHROMIUM_BUILDTOOLS_PATH="$TERMUX_PKG_SRCDIR/buildtools"
}

termux_step_get_source() {
	# Fetch depot_tools
	__tur_setup_depot_tools

	# Fetch chromium source
	local __cr_src_dir="$HOME/chromium-sources/chromium"
	if [ ! -f "$TERMUX_PKG_CACHEDIR/.chromium-source-fetched" ]; then
		mkdir -p "$__cr_src_dir"
		pushd "$__cr_src_dir"
		fetch --nohooks chromium || (
			cd src && git reset --hard && git checkout main && git pull &&
			_remote_main="$(git rev-parse origin/main)" && cd .. &&
			gclient sync -D --nohooks --verbose --revision src@$_remote_main &&
			gclient fetch --verbose
		)
		pushd src
		gclient runhooks
		popd # "$__cr_src_dir/src"
		popd # "$__cr_src_dir"
		touch "$TERMUX_PKG_CACHEDIR/.chromium-source-fetched"
	fi

	# Install nodejs
	termux_setup_nodejs

	# Fetch electron source without checking out chromium source
	local __electron_src_dir="$HOME/chromium-sources/electron"
	if [ ! -f "$TERMUX_PKG_CACHEDIR/.electron-source-fetched" ]; then
		mkdir -p "$__electron_src_dir"
		pushd "$__electron_src_dir"
		gclient config --name "src/electron" --unmanaged https://github.com/electron/electron --custom-var=checkout_chromium=False --verbose
		gclient fetch --verbose
		gclient sync --nohooks --with_branch_heads --with_tags --verbose
		(cd src/electron && git reset --hard && git checkout main && git pull &&
		_remote_main="$(git rev-parse origin/main)" && cd ../.. &&
		gclient sync -D --nohooks --with_branch_heads --with_tags --verbose --revision src/electron@$_remote_main &&
		gclient fetch --verbose)
		popd # "$__electron_src_dir"
		touch "$TERMUX_PKG_CACHEDIR/.electron-source-fetched"
	fi

	# Layer 1, contains the source code of given version
	local __layer1_dir="$TERMUX_PKG_CACHEDIR/electron-layer-1"
	local __layer1_marker_file="$TERMUX_PKG_CACHEDIR/.layer1-fetched"
	if [ ! -f "$__layer1_marker_file" ] || [ "$(cat $__layer1_marker_file)" != "$TERMUX_PKG_VERSION" ]; then
		if __tur_chromium_is_mountpoint "$__layer1_dir/merged" ; then
			__tur_chromium_sudo umount "$__layer1_dir/merged"
		fi
		mkdir -p "$__layer1_dir"
		pushd "$__layer1_dir"
		__tur_chromium_sudo rm -rf merged/ upperdir/ workdir/
		mkdir -p merged/ upperdir/ workdir/
		__tur_chromium_sudo mount -t overlay -o lowerdir=$__electron_src_dir:$__cr_src_dir,upperdir=$__layer1_dir/upperdir,workdir=$__layer1_dir/workdir overlay $__layer1_dir/merged
		rm -rf "$__layer1_dir/merged/.cipd"
		popd # "$__layer1_dir"
		pushd "$__layer1_dir/merged"
		gclient config --name "src/electron" --unmanaged https://github.com/electron/electron --verbose
		gclient sync --with_branch_heads --with_tags --no-history --nohooks --revision v$TERMUX_PKG_VERSION --verbose
		gclient fetch --verbose
		popd # "$__layer1_dir/merged"
		echo "$TERMUX_PKG_VERSION" > "$__layer1_marker_file"
	else
		if ! __tur_chromium_is_mountpoint "$__layer1_dir/merged" ; then
			__tur_chromium_sudo mount -t overlay -o lowerdir=$__electron_src_dir:$__cr_src_dir,upperdir=$__layer1_dir/upperdir,workdir=$__layer1_dir/workdir overlay $__layer1_dir/merged
		fi
	fi

	# Layer 2, run hooks
	local __layer2_dir="$TERMUX_PKG_CACHEDIR/electron-layer-2"
	local __layer2_marker_file="$TERMUX_PKG_CACHEDIR/.layer2-fetched"
	if [ ! -f "$__layer2_marker_file" ] || [ "$(cat $__layer2_marker_file)" != "$TERMUX_PKG_VERSION" ]; then
		if __tur_chromium_is_mountpoint "$__layer2_dir/merged" ; then
			__tur_chromium_sudo umount "$__layer2_dir/merged"
		fi
		mkdir -p "$__layer2_dir"
		pushd "$__layer2_dir"
		__tur_chromium_sudo rm -rf merged/ upperdir/ workdir/
		mkdir -p merged/ upperdir/ workdir/
		__tur_chromium_sudo mount -t overlay -o lowerdir=$__layer1_dir/upperdir:$__electron_src_dir:$__cr_src_dir,upperdir=$__layer2_dir/upperdir,workdir=$__layer2_dir/workdir overlay $__layer2_dir/merged
		popd # "$__layer2_dir"
		pushd "$__layer2_dir/merged"
		gclient runhooks --verbose
		popd # "$__layer2_dir/merged"
		echo "$TERMUX_PKG_VERSION" > "$__layer2_marker_file"
	else
		if ! __tur_chromium_is_mountpoint "$__layer2_dir/merged" ; then
			__tur_chromium_sudo mount -t overlay -o lowerdir=$__layer1_dir/upperdir:$__electron_src_dir:$__cr_src_dir,upperdir=$__layer2_dir/upperdir,workdir=$__layer2_dir/workdir overlay $__layer2_dir/merged
		fi
	fi


	# Layer 3, the real work dir, waiting for patches
	local __layer3_dir="$TERMUX_PKG_CACHEDIR/electron-layer-3"
	if __tur_chromium_is_mountpoint "$__layer3_dir/merged" ; then
		__tur_chromium_sudo umount "$__layer3_dir/merged"
	fi
	mkdir -p "$__layer3_dir"
	pushd "$__layer3_dir"
	__tur_chromium_sudo rm -rf merged/ upperdir/ workdir/
	mkdir -p merged/ upperdir/ workdir/
	__tur_chromium_sudo mount -t overlay -o lowerdir=$__layer2_dir/upperdir:$__layer1_dir/upperdir:$__electron_src_dir:$__cr_src_dir,upperdir=$__layer3_dir/upperdir,workdir=$__layer3_dir/workdir overlay $__layer3_dir/merged
	popd # "$__layer3_dir"

	# Now, we've get the real source of given commit, just provide the symlink
	rm -rf $TERMUX_PKG_SRCDIR
	ln -sfr "$__layer3_dir/merged/src" $TERMUX_PKG_SRCDIR

	# Solve error like `.git/packed-refs is dirty`
	pushd $TERMUX_PKG_SRCDIR
	git pack-refs --all
	cd electron
	git pack-refs --all
	popd # $TERMUX_PKG_SRCDIR
}

termux_step_post_get_source() {
	# Apply patches related to chromium
	local f
	for f in $(find "$TERMUX_PKG_BUILDER_DIR/cr-patches" -maxdepth 1 -type f -name *.patch | sort); do
		echo "Applying patch: $(basename $f)"
		patch -p1 < "$f"
	done

	bash

	# Apply patches for jumbo build
	# local f
	# for f in $(find "$TERMUX_PKG_BUILDER_DIR/jumbo-patches" -maxdepth 1 -type f -name *.patch | sort); do
	# 	echo "Applying patch: $(basename $f)"
	# 	patch -p1 < "$f"
	# done

	# Write version to file
	echo "$TERMUX_PKG_VERSION" > $TERMUX_PKG_SRCDIR/electron/ELECTRON_VERSION
}

termux_step_configure() {
	cd $TERMUX_PKG_SRCDIR
	termux_setup_ninja
	__tur_setup_depot_tools

	# Remove termux's dummy pkg-config
	local _target_pkg_config=$(command -v pkg-config)
	local _host_pkg_config="$(cat $_target_pkg_config | grep exec | awk '{print $2}')"
	rm -rf $TERMUX_PKG_CACHEDIR/host-pkg-config-bin
	mkdir -p $TERMUX_PKG_CACHEDIR/host-pkg-config-bin
	ln -s $_host_pkg_config $TERMUX_PKG_CACHEDIR/host-pkg-config-bin/pkg-config
	export PATH="$TERMUX_PKG_CACHEDIR/host-pkg-config-bin:$PATH"

	# Setup rust toolchain and clang toolchain
	./tools/rust/update_rust.py
	./tools/clang/scripts/update.py

	# Install amd64 rootfs if necessary, it should have been installed by source hooks.
	build/linux/sysroot_scripts/install-sysroot.py --sysroots-json-path=electron/script/sysroots.json --arch=amd64
	local _amd64_sysroot_path="$(pwd)/build/linux/$(ls build/linux | grep 'amd64-sysroot')"

	local CARGO_TARGET_NAME="${TERMUX_ARCH}-linux-android"
	if [[ "${TERMUX_ARCH}" == "arm" ]]; then
		CARGO_TARGET_NAME="armv7-linux-androideabi"
	fi

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
		popd
		mv $TERMUX_PKG_TMPDIR/sysroot $TERMUX_PKG_CACHEDIR/sysroot-$TERMUX_ARCH
	fi

	# Construct args
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
	elif [ "$TERMUX_ARCH" = "arm" ]; then
		# Install i386 rootfs if necessary, it should have been installed by source hooks.
		build/linux/sysroot_scripts/install-sysroot.py --sysroots-json-path=electron/script/sysroots.json --arch=i386
		local _i386_sysroot_path="$(pwd)/build/linux/$(ls build/linux | grep 'i386-sysroot')"
		_target_cpu="arm"
		_v8_current_cpu="x86"
		_v8_sysroot_path="$_i386_sysroot_path"
		_v8_toolchain_name="clang_x86_v8_arm"
	elif [ "$TERMUX_ARCH" = "x86_64" ]; then
		_target_cpu="x64"
		_v8_current_cpu="x64"
		_v8_sysroot_path="$_amd64_sysroot_path"
		_v8_toolchain_name="host"
	fi

	local _common_args_file=$TERMUX_PKG_TMPDIR/common-args-file
	rm -f $_common_args_file
	touch $_common_args_file

	echo "
import(\"$TERMUX_PKG_SRCDIR/electron/build/args/release.gn\")
override_electron_version = \"$TERMUX_PKG_VERSION\"
# Do not build with symbols
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
electron_js2c_toolchain = \"$TERMUX_PKG_CACHEDIR/custom-toolchain:$_v8_toolchain_name\"
clang_use_chrome_plugins = false
dcheck_always_on = false
chrome_pgo_phase = 0
treat_warnings_as_errors = false
# Use system libraries as little as possible
use_bundled_fontconfig = false
use_system_freetype = false
use_system_libdrm = true
use_system_libffi = false
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
angle_enable_abseil = false
rtc_use_pipewire = false
use_vaapi = false
# See comments on Chromium package
enable_nacl = false
is_cfi = false
use_cfi_icall = false
use_thin_lto = false
# Enable rust
custom_target_rust_abi_target = \"$CARGO_TARGET_NAME\"
llvm_android_mainline = true
exclude_unwind_tables = false
# Enable jumbo build (unified build)
use_jumbo_build = true
" >> $_common_args_file

	if [ "$TERMUX_ARCH" = "arm" ]; then
		echo "arm_arch = \"armv7-a\"" >> $_common_args_file
		echo "arm_float_abi = \"softfp\"" >> $_common_args_file
	fi

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
	mkdir -p $TERMUX_PKG_BUILDDIR/out/Release
	cat $_common_args_file > $TERMUX_PKG_BUILDDIR/out/Release/args.gn
	gn gen $TERMUX_PKG_BUILDDIR/out/Release || bash
}

termux_step_make() {
	cd $TERMUX_PKG_BUILDDIR
	ninja -C $TERMUX_PKG_BUILDDIR/out/Release electron:node_headers electron electron_license chromium_licenses -k 0 || bash
	rm -rf "$TERMUX_PKG_CACHEDIR/sysroot-$TERMUX_ARCH"
}

termux_step_make_install() {
	cd $TERMUX_PKG_BUILDDIR
	mkdir -p $TERMUX_PREFIX/lib/$TERMUX_PKG_NAME

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

	cp "${normal_files[@]/#/out/Release/}" "$TERMUX_PREFIX/lib/$TERMUX_PKG_NAME/"

	cp -Rf out/Release/angledata $TERMUX_PREFIX/lib/$TERMUX_PKG_NAME/
	cp -Rf out/Release/locales $TERMUX_PREFIX/lib/$TERMUX_PKG_NAME/
	cp -Rf out/Release/resources $TERMUX_PREFIX/lib/$TERMUX_PKG_NAME/

	chmod +x $TERMUX_PREFIX/lib/$TERMUX_PKG_NAME/electron

	# Install LICENSE file
	cp out/Release/LICENSE{,S.chromium.html} $TERMUX_PREFIX/lib/$TERMUX_PKG_NAME/

	# Install as the default electron
	ln -sfr $TERMUX_PREFIX/lib/$TERMUX_PKG_NAME/electron $TERMUX_PREFIX/bin/electron
	if [ "$TERMUX_PKG_NAME" != "electron" ]; then
		ln -sfr $TERMUX_PREFIX/lib/$TERMUX_PKG_NAME $TERMUX_PREFIX/lib/electron
	fi
}

termux_step_install_license() {
	mkdir -p $TERMUX_PREFIX/share/doc/$TERMUX_PKG_NAME
	cp out/Release/LICENSE{,S.chromium.html} $TERMUX_PREFIX/share/doc/$TERMUX_PKG_NAME/
}

termux_step_post_make_install() {
	# Remove the dummy files
	rm $TERMUX_PREFIX/lib/lib{{pthread,resolv,ffi_pic}.a,rt.so}
}


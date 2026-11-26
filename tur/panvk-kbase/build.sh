TERMUX_PKG_HOMEPAGE=https://github.com/zenithblue-oss/panvk-kbase-android
TERMUX_PKG_DESCRIPTION="Mesa PanVK Vulkan driver for Android Mali GPUs (kbase)"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_LICENSE_FILE="docs/license.rst"
TERMUX_PKG_MAINTAINER="JesusChapman <developer@jesuschapman.me>"
TERMUX_PKG_VERSION=0.1.0-rc3
TERMUX_PKG_SRCURL=https://gitlab.freedesktop.org/mesa/mesa/-/archive/5a07217f034b3e50d8c7c7794f97a2df1742613b/mesa-5a07217f034b3e50d8c7c7794f97a2df1742613b.tar.gz
TERMUX_PKG_SHA256=5b1fadb9f8d790ef9adc36c37c115634b8cc051c9cded05a31d941671f1cec2e
TERMUX_PKG_DEPENDS="libdrm, libx11, libxcb, libxshmfence, vulkan-loader-generic, zlib"
TERMUX_PKG_BUILD_DEPENDS="libx11, libxcb, vulkan-headers, xorgproto"
TERMUX_PKG_HOSTBUILD=true
TERMUX_PKG_EXCLUDED_ARCHES="arm, i686, x86_64"
# API 29: bionic inlines call_once in threads.h (libc exports it from 30).
TERMUX_PKG_API_LEVEL=29
TERMUX_PKG_AUTO_UPDATE=false
# PanVK-kbase RC3 series on this Mesa pin; flags mirror upstream build-android.sh.
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-Dplatforms=android,x11
-Dandroid-stub=true
-Dandroid-strict=false
-Dgallium-drivers=
-Dvulkan-drivers=panfrost
-Dpanfrost-kmds=kbase
-Dmesa-clc=system
-Dprecomp-compiler=system
-Dxlib-lease=disabled
-Degl=disabled
-Dgles1=disabled
-Dgles2=disabled
-Dopengl=false
-Dglx=disabled
-Dgbm=disabled
-Dlibunwind=disabled
-Dzstd=disabled
-Dcpp_link_args=-static-libstdc++
"

termux_step_post_get_source() {
	cp -r "$TERMUX_PKG_BUILDER_DIR/files/." "$TERMUX_PKG_SRCDIR/"
}

termux_step_host_build() {
	local srcdir
	if [[ "$TERMUX_ON_DEVICE_BUILD" == "false" ]]; then
		srcdir="$TERMUX_PKG_SRCDIR"
	else
		srcdir="$TERMUX_PKG_HOSTBUILD_DIR/source"
		cp -r "$TERMUX_PKG_SRCDIR" "$srcdir"
		cp -r "$TERMUX_PKG_BUILDER_DIR/files/." "$srcdir/"
		local p
		for p in "$TERMUX_PKG_BUILDER_DIR"/*.patch; do
			echo "Applying $(basename "${p}")"
			patch --silent -p1 -d "$srcdir" <"${p}"
		done
	fi

	export HOSTBUILD_ROOTFS="${TERMUX_PKG_HOSTBUILD_DIR}/ubuntu_packages"

	if [[ "$TERMUX_ON_DEVICE_BUILD" == "false" ]]; then
		local HOST_TRIPLET="$(gcc -dumpmachine)"
		mkdir -p "${HOSTBUILD_ROOTFS}/usr/share/pkgconfig"
		PKG_CONFIG_LIBDIR="${HOSTBUILD_ROOTFS}/usr/lib/x86_64-linux-gnu/pkgconfig"
		PKG_CONFIG_LIBDIR+=":${HOSTBUILD_ROOTFS}/usr/share/pkgconfig/"
		PKG_CONFIG_LIBDIR+=":$(grep 'DefaultSearchPaths:' "/usr/share/pkgconfig/personality.d/${HOST_TRIPLET}.personality" | cut -d ' ' -f 2)"
		export PKG_CONFIG_LIBDIR
		export PKG_CONFIG_PATH="$PKG_CONFIG_LIBDIR"
		export PATH="${HOSTBUILD_ROOTFS}/usr/bin:${PATH}"
	fi

	AR=
	CC=
	CFLAGS=
	CPPFLAGS=
	CXX=
	CXXFLAGS=
	LD=
	LDFLAGS=
	PKG_CONFIG=
	STRIP=
	termux_setup_meson
	unset AR CC CFLAGS CPPFLAGS CXX CXXFLAGS LD LDFLAGS PKG_CONFIG STRIP
	termux_setup_rust

	if [[ "$TERMUX_ON_DEVICE_BUILD" == "false" ]]; then
		termux_download_ubuntu_packages \
			"libllvmspirvlib-$TERMUX_HOST_LLVM_MAJOR_VERSION-dev" \
			"libllvm$TERMUX_HOST_LLVM_MAJOR_VERSION" \
			"libllvmspirvlib$TERMUX_HOST_LLVM_MAJOR_VERSION.1" \
			"libclang-$TERMUX_HOST_LLVM_MAJOR_VERSION-dev" \
			"libclang-cpp$TERMUX_HOST_LLVM_MAJOR_VERSION-dev" \
			"libclang-common-$TERMUX_HOST_LLVM_MAJOR_VERSION-dev" \
			libz3-4 \
			spirv-tools-dev \
			spirv-tools-headers \
			libdrm-dev libdrm2 libdrm-common libdrm-amdgpu1 libdrm-intel1 \
			libdrm-nouveau2 libdrm-radeon1 libpciaccess-dev libpciaccess0

		local LLVM_CONFIG_ORIG="/usr/bin/llvm-config-$TERMUX_HOST_LLVM_MAJOR_VERSION"
		local LLVM_CONFIG_WRAPPER="${HOSTBUILD_ROOTFS}${LLVM_CONFIG_ORIG}"
		mkdir -p "$(dirname "$LLVM_CONFIG_WRAPPER")"
		cat <<-EOF >"$LLVM_CONFIG_WRAPPER"
			#!/bin/bash
			if [[ "\$1" == "--libdir" ]]; then
				echo "$HOSTBUILD_ROOTFS/usr/lib/llvm-$TERMUX_HOST_LLVM_MAJOR_VERSION/lib"
			elif [[ "\$1" == "--includedir" ]]; then
				echo "$HOSTBUILD_ROOTFS/usr/lib/llvm-$TERMUX_HOST_LLVM_MAJOR_VERSION/include"
			else
				$LLVM_CONFIG_ORIG "\$@"
			fi
		EOF
		chmod +x "$LLVM_CONFIG_WRAPPER"
		export CPPFLAGS="-I$($LLVM_CONFIG_WRAPPER --includedir)"
		CPPFLAGS+=" -I$HOSTBUILD_ROOTFS/usr/include"
		CPPFLAGS+=" -I$HOSTBUILD_ROOTFS/usr/include/libdrm"
		export LDFLAGS="-L$HOSTBUILD_ROOTFS/usr/lib/x86_64-linux-gnu"
	fi

	cargo install --force --locked bindgen-cli

	$TERMUX_MESON setup \
		"$srcdir" build \
		--prefix "$HOSTBUILD_ROOTFS/usr" \
		-Dbuildtype=release \
		-Dplatforms= \
		-Dgallium-drivers= \
		-Dvulkan-drivers=panfrost \
		-Dinstall-mesa-clc=true \
		-Dmesa-clc=enabled \
		-Dinstall-precomp-compiler=true \
		-Dprecomp-compiler=enabled \
		-Dllvm=enabled \
		-Dzstd=disabled
	export LD_LIBRARY_PATH="$HOSTBUILD_ROOTFS/usr/lib/x86_64-linux-gnu"
	# mesa_clc finds clang resource headers (opencl-c-base.h) relative to
	# its own binary; link the extracted Ubuntu set into both places it runs from.
	_clang_res="$HOSTBUILD_ROOTFS/usr/lib/llvm-$TERMUX_HOST_LLVM_MAJOR_VERSION/lib/clang/$TERMUX_HOST_LLVM_MAJOR_VERSION/include"
	mkdir -p "$TERMUX_PKG_HOSTBUILD_DIR/build/src/compiler/lib/clang"
	ln -sfn "$_clang_res" "$TERMUX_PKG_HOSTBUILD_DIR/build/src/compiler/lib/clang/$TERMUX_HOST_LLVM_MAJOR_VERSION"
	$TERMUX_MESON compile -C build \
		src/compiler/clc/mesa_clc \
		src/compiler/spirv/vtn_bindgen2 \
		src/panfrost/clc/panfrost_compile
	$TERMUX_MESON install -C build
	mkdir -p "$HOSTBUILD_ROOTFS/usr/lib/clang"
	ln -sfn "$_clang_res" "$HOSTBUILD_ROOTFS/usr/lib/clang/$TERMUX_HOST_LLVM_MAJOR_VERSION"

	unset AR CC CFLAGS CPPFLAGS CXX CXXFLAGS LD LDFLAGS PKG_CONFIG STRIP PKG_CONFIG_LIBDIR PKG_CONFIG_PATH
	if [[ "$TERMUX_ON_DEVICE_BUILD" == "false" ]]; then
		rm "$LLVM_CONFIG_WRAPPER"
	fi
}

termux_step_pre_configure() {
	rm -f "$TERMUX_HOSTBUILD_MARKER"

	termux_setup_cmake
	export HOSTBUILD_ROOTFS="${TERMUX_PKG_HOSTBUILD_DIR}/ubuntu_packages"
	export PATH="$HOSTBUILD_ROOTFS/usr/bin:$PATH"
	export LD_LIBRARY_PATH="$HOSTBUILD_ROOTFS/usr/lib/x86_64-linux-gnu"
	termux_setup_meson
}

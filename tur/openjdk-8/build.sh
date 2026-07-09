TERMUX_PKG_HOMEPAGE=https://openjdk.java.net
TERMUX_PKG_DESCRIPTION="Java development kit and runtime"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@SrErikCoderx"
TERMUX_PKG_VERSION="8.0.492"
TERMUX_PKG_SRCURL=(
    https://github.com/openjdk/jdk8u/archive/9cecb1477fff90f2d367a4df0a94cb44510d1ba9.tar.gz
    https://github.com/openjdk/aarch32-port-jdk8u/archive/5007d4efb98eef1ac2507a9580d7a1754c6797d3.tar.gz
)
TERMUX_PKG_SHA256=(
    8e44d6a9c04f590f3f0c6a6b95a74733ba8c347f4c50993dea7d68e06861ff1e
    395e1cec295d3b885a65efe75d59d231946b91d885052c52602f96c5c3f0cba5
)
TERMUX_PKG_DEPENDS="freetype"
TERMUX_PKG_RECOMMENDS="fontconfig, ca-certificates-java, resolv-conf"
TERMUX_PKG_SUGGESTS="cups"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_HAS_DEBUG=false
TERMUX_PKG_NO_STATICSPLIT=true
TERMUX_PKG_HOSTBUILD=true
TERMUX_PKG_UNDEF_SYMBOLS_FILES="all"
TERMUX_PKG_AUTO_UPDATE=true

# Override: download tarballs but don't auto-extract.
# clonejdk.sh handles selective extraction based on TARGET_JDK.
termux_step_get_source() {
	if [ -z "${TERMUX_PKG_SRCURL}" ] || [ "${TERMUX_PKG_SKIP_SRC_EXTRACT:-false}" = "true" ] || [ "${TERMUX_PKG_METAPACKAGE:-false}" = "true" ]; then
		mkdir -p "$TERMUX_PKG_SRCDIR"
		return
	fi
	termux_download "${TERMUX_PKG_SRCURL[0]}" \
		"$TERMUX_PKG_CACHEDIR/jdk8u.tar.gz" \
		"${TERMUX_PKG_SHA256[0]}"
	termux_download "${TERMUX_PKG_SRCURL[1]}" \
		"$TERMUX_PKG_CACHEDIR/aarch32.tar.gz" \
		"${TERMUX_PKG_SHA256[1]}"
	mkdir -p "$TERMUX_PKG_SRCDIR"
}

_ensure_patchelf() {
	[ -x "$TERMUX_PKG_CACHEDIR/patchelf-0.18.0/bin/patchelf" ] && return
	local url="https://github.com/NixOS/patchelf/releases/download/0.18.0/patchelf-0.18.0-x86_64.tar.gz"
	local arc="$TERMUX_PKG_CACHEDIR/patchelf.tar.gz"
	curl -fsSL "$url" -o "$arc"
	mkdir -p "$TERMUX_PKG_CACHEDIR/patchelf-0.18.0/bin"
	tar -xzf "$arc" -C "$TERMUX_PKG_CACHEDIR/patchelf-0.18.0"
}

termux_step_host_build() {
	local url="https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u492-b09/OpenJDK8U-jdk_x64_linux_hotspot_8u492b09.tar.gz"
	local arc="$TERMUX_PKG_CACHEDIR/jdk8-boot-x64.tar.gz"
	local sha="da257f161d7f8c6ca5b0e5d9e4090f65ac28c5e398072e68b8ae87988b1d1a2e"
	termux_download "$url" "$arc" "$sha"
	tar -xf "$arc" --strip-components=1 -C "$TERMUX_PKG_HOSTBUILD_DIR"
}

termux_step_setup_toolchain() {
	local hostpkgs_marker="$TERMUX_PKG_CACHEDIR/.host-pkgs-installed"
	if [ ! -f "$hostpkgs_marker" ]; then
		env -i PATH="$PATH" sudo apt update
		env -i PATH="$PATH" sudo apt -y install autoconf python3 python-is-python3 unzip zip \
			systemtap-sdt-dev gcc-multilib g++-multilib cmake patchelf llvm \
			libasound2-dev libelf-dev libfontconfig1-dev \
			libx11-dev libxext-dev libxrender-dev libxrandr-dev libxinerama-dev \
			libxi-dev libxft-dev libxcursor-dev libxfixes-dev libxss-dev \
			libxv-dev libxxf86vm-dev libxtst-dev libxt-dev libice-dev libsm-dev
		touch "$hostpkgs_marker"
	fi
	export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
	export STRIP=llvm-strip
	export READELF=llvm-readelf
	export JAVA_HOME="$TERMUX_PKG_HOSTBUILD_DIR"
	export USER=louise
	export LOGNAME=louise
	mkdir -p "$TERMUX_PKG_SRCDIR/termux-elf-cleaner/build"
	cp "$TERMUX_ELF_CLEANER" "$TERMUX_PKG_SRCDIR/termux-elf-cleaner/build/termux-elf-cleaner"
	_ensure_patchelf
	export PATH="$TERMUX_PKG_CACHEDIR/patchelf-0.18.0/bin:$PATH"
}

termux_step_pre_configure() {
	local _arch
	case "$TERMUX_ARCH" in
		aarch64) _arch="aarch64" ;;
		arm)     _arch="aarch32" ;;
		x86_64)  _arch="x86_64" ;;
		i686)    _arch="x86" ;;
	esac
	export TARGET_JDK="$_arch"
	export TERMUX_PKG_CACHEDIR
	cd "$TERMUX_PKG_SRCDIR"
	bash "$TERMUX_PKG_BUILDER_DIR/ci_build_arch_${_arch}.sh"
}

termux_step_configure() {
	# The massage step calls ${HOST}-clang -print-libgcc-file-name and
	# -print-file-name=libomp.{so,a} for undefined-symbols QC.  With
	# TERMUX_PKG_UNDEF_SYMBOLS_FILES=all the actual check is skipped,
	# but the commands must still succeed and LIBOMP_SYMBOLS must be
	# non-empty (otherwise create_grep_pattern_openmp crashes with
	# "unbound variable").  Point to NDK r29's clang with the correct
	# --target so it finds both libgcc and libomp in NDK 29's sysroot.
	local ndk_bin="$NDK/toolchains/llvm/prebuilt/linux-x86_64/bin"
	local wrapdir="$TERMUX_PKG_CACHEDIR/ndk-wrappers"
	mkdir -p "$wrapdir"
	local target="$TERMUX_HOST_PLATFORM"
	if [ "$TERMUX_ARCH" = "arm" ]; then
		target="armv7a-linux-androideabi"
	fi
	cat > "$wrapdir/${TERMUX_HOST_PLATFORM}-clang" <<-CLANG
#!/bin/bash
exec "$ndk_bin/clang" --target=${target}${TERMUX_PKG_API_LEVEL} "\$@"
CLANG
	chmod +x "$wrapdir/${TERMUX_HOST_PLATFORM}-clang"
	export PATH="$wrapdir:$PATH"
}
termux_step_make() { :; }

termux_step_make_install() {
	local _jdkout_dir
	case "$TERMUX_ARCH" in
		aarch64) _jdkout_dir="arm64" ;;
		arm)     _jdkout_dir="arm" ;;
		x86_64)  _jdkout_dir="x86_64" ;;
		i686)    _jdkout_dir="x86" ;;
	esac

	local jdk_home="$TERMUX_PREFIX/lib/jvm/java-8-openjdk"
	rm -rf "$jdk_home"
	mkdir -p "$jdk_home"
	cp -r "$TERMUX_PKG_SRCDIR/jdkout/$_jdkout_dir/"* "$jdk_home/"

	if [ -d "$TERMUX_PKG_BUILDER_DIR/jre_override" ]; then
		cp -Rf "$TERMUX_PKG_BUILDER_DIR/jre_override/lib/"* "$jdk_home/jre/lib/" 2>/dev/null || true
	fi

	local jdk_lib_arch
	jdk_lib_arch=$(basename "$(find "$jdk_home/lib" -maxdepth 1 -type d ! -name lib | head -1)")

	local rpath="${jdk_home}/lib/${jdk_lib_arch}:${jdk_home}/lib/${jdk_lib_arch}/jli"
	rpath+=":${jdk_home}/jre/lib/${jdk_lib_arch}:${jdk_home}/jre/lib/${jdk_lib_arch}/jli"
	rpath+=":${jdk_home}/jre/lib/${jdk_lib_arch}/server:${jdk_home}/jre/lib/${jdk_lib_arch}/client"
	rpath+=":${jdk_home}/lib:${jdk_home}/jre/lib"
	rpath+=":${TERMUX_PREFIX}/lib"

	find "$jdk_home/bin" -maxdepth 1 -type f -print0 | while IFS= read -r -d '' bin; do
		patchelf --set-rpath "$rpath" "$bin" || echo "WARN: patchelf failed on $bin" >&2
	done

	find "$jdk_home" -name "*.so" -print0 | while IFS= read -r -d '' lib; do
		patchelf --set-rpath "$rpath" "$lib" || echo "WARN: patchelf failed on $lib" >&2
	done

	for dir in "$jdk_home/lib/$jdk_lib_arch" \
		"$jdk_home/jre/lib/$jdk_lib_arch"; do
		rm -f "$dir/librt.so"
		case "$TERMUX_ARCH" in
			aarch64|x86_64) ln -sf /system/lib64/libc.so "$dir/librt.so" ;;
			*)              ln -sf /system/lib/libc.so  "$dir/librt.so" ;;
		esac
	done

	for variant_dir in server client; do
		local jsig_link="$jdk_home/jre/lib/$jdk_lib_arch/$variant_dir/libjsig.so"
		[ -f "$jsig_link" ] && ln -sf ../libjsig.so "$jsig_link" 2>/dev/null || true
	done

	mkdir -p "$jdk_home/etc/profile.d"
	echo "export JAVA_HOME=$jdk_home/" > "$jdk_home/etc/profile.d/java.sh"
}

termux_step_post_make_install() {
	find "$TERMUX_PREFIX/lib/jvm/java-8-openjdk" -name "*.diz" -delete 2>/dev/null || true

	if [ -d "$TERMUX_PREFIX/lib/jvm/java-8-openjdk/man/man1" ]; then
		cd "$TERMUX_PREFIX/lib/jvm/java-8-openjdk/man/man1"
		for manpage in *.1; do
			gzip "$manpage"
		done
	fi

	binaries="$(find "$TERMUX_PREFIX/lib/jvm/java-8-openjdk/bin" -executable -type f | xargs -I{} basename "{}" | xargs echo)"
	manpages="$(find "$TERMUX_PREFIX/lib/jvm/java-8-openjdk/man/man1" -name "*.1.gz" | xargs -I{} basename "{}" | xargs echo)"

	local failure=false
	for binary in $binaries; do
		grep -q "lib/jvm/java-8-openjdk/bin/${binary}$" \
			"$TERMUX_PKG_BUILDER_DIR"/openjdk-8.alternatives || {
			echo "ERROR: Missing entry for binary: $binary in openjdk-8.alternatives"
			failure=true
		}
	done
	for manpage in $manpages; do
		grep -q "lib/jvm/java-8-openjdk/man/man1/${manpage}$" \
			"$TERMUX_PKG_BUILDER_DIR"/openjdk-8.alternatives || {
			echo "ERROR: Missing entry for manpage: $manpage in openjdk-8.alternatives"
			failure=true
		}
	done
	if [[ "$failure" = true ]]; then
		termux_error_exit "openjdk-8.alternatives is not up to date, please update it."
	fi
}

termux_pkg_auto_update() {
	local main_tag arm_tag hash1 hash2 ver_raw new_version

	main_tag=$(git ls-remote --tags https://github.com/openjdk/jdk8u.git \
		| awk -F/ '{print $NF}' \
		| grep -E '^jdk8u[0-9]+-ga$' \
		| sort -t u -k2 -V \
		| tail -1)
	[[ -z "$main_tag" ]] && termux_error_exit "no GA tag found for jdk8u"

	ver_raw="${main_tag#jdk8u}"
	ver_raw="${ver_raw%-ga}"

	arm_tag=$(git ls-remote --tags https://github.com/openjdk/aarch32-port-jdk8u.git \
		| awk -F/ '{print $NF}' \
		| grep -E "^jdk8u${ver_raw}-ga-aarch32-[0-9]+\$")
	[[ -z "$arm_tag" ]] && termux_error_exit "no aarch32-specific tag found for version ${ver_raw}"

	hash1=$(git ls-remote https://github.com/openjdk/jdk8u.git "refs/tags/$main_tag" \
		| awk '{print $1}' | head -1)
	hash2=$(git ls-remote https://github.com/openjdk/aarch32-port-jdk8u.git "refs/tags/$arm_tag" \
		| awk '{print $1}' | head -1)
	[[ -z "$hash1" ]] && termux_error_exit "no commit for tag in jdk8u"
	[[ -z "$hash2" ]] && termux_error_exit "no commit for tag in aarch32-port"

	new_version="8.0.${ver_raw}"

	if ! termux_pkg_is_update_needed "${TERMUX_PKG_VERSION#*:}" "${new_version}"; then
		echo "INFO: No update needed. Already at version '${TERMUX_PKG_VERSION}'."
		return 0
	fi

	# Solo tocar SRCURL si realmente vamos a completar el update
	# (mismo gate que usa termux_pkg_upgrade_version internamente)
	if [ "${BUILD_PACKAGES:-true}" != "true" ]; then
		echo "INFO: [dry-run] Would update openjdk-8 to ${new_version} (SRCURL not modified)."
		return 0
	fi

	sed -i \
		"s|https://github.com/openjdk/jdk8u/archive/[a-f0-9]*\.tar\.gz|https://github.com/openjdk/jdk8u/archive/${hash1}.tar.gz|g" \
		"${TERMUX_PKG_BUILDER_DIR}/build.sh"
	sed -i \
		"s|https://github.com/openjdk/aarch32-port-jdk8u/archive/[a-f0-9]*\.tar\.gz|https://github.com/openjdk/aarch32-port-jdk8u/archive/${hash2}.tar.gz|g" \
		"${TERMUX_PKG_BUILDER_DIR}/build.sh"

	termux_pkg_upgrade_version "${new_version}" --skip-version-check
}

termux_step_create_debscripts() {
	return 0
}

TERMUX_PKG_HOMEPAGE=http://gcc.gnu.org/
TERMUX_PKG_DESCRIPTION="GNU C compiler"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_DEPENDS="binutils, libc++, libgmp, libmpfr, libmpc, libisl, zlib"
TERMUX_PKG_VERSION="15.3.0"
TERMUX_PKG_MAINTAINER="@licy183"
TERMUX_PKG_SRCURL="https://mirrors.kernel.org/gnu/gcc/gcc-${TERMUX_PKG_VERSION}/gcc-${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=d6c1a7d2da0f2a3bc52c7d02fdd4a531ead78fd694dd31cae1ca532cf5e2b7e3
TERMUX_PKG_BREAKS="binutils-is-llvm"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_NO_STATICSPLIT=true
TERMUX_PKG_ON_DEVICE_BUILD_NOT_SUPPORTED=true
TERMUX_PKG_EXTRA_CONFIGURE_ARGS+="\
--enable-initfini-array
--enable-default-pie
--enable-languages=c,c++,fortran
--enable-lto
--enable-host-shared
--enable-host-libquadmath
--enable-libatomic
--enable-libatomic-ifuncs=no
--enable-libbacktrace
--enable-libquadmath
--enable-libgomp
--enable-gold
--enable-version-specific-runtime-libs
--enable-eh-frame-hdr-for-static
--disable-shared
--disable-libmpx
--disable-libssp
--disable-libstdcxx
--disable-multilib
--disable-tls
--with-ld=$TERMUX_PREFIX/bin/ld.bfd
--with-libatomic
--with-system-zlib
--with-gmp=$TERMUX_PREFIX
--with-mpfr=$TERMUX_PREFIX
--with-mpc=$TERMUX_PREFIX
--with-isl=$TERMUX_PREFIX
--with-gxx-include-dir=$TERMUX_PREFIX/include/c++/v1
--program-suffix=-15
"

TERMUX_PKG_RM_AFTER_INSTALL="
share/info
share/man/man7
"

_ARCH_SPECS=""

if [ "$TERMUX_ARCH" = "arm" ]; then
	TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" --with-arch=armv7-a --with-float=soft --with-fpu=vfp"
elif [ "$TERMUX_ARCH" = "aarch64" ]; then
	_ARCH_SPECS="\n*cc1:\n+ -ffixed-x18\n\n*cc1plus:\n+ -ffixed-x18\n"
	TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" --enable-fix-cortex-a53-835769 --enable-fix-cortex-a53-843419"
elif [ "$TERMUX_ARCH" = "i686" ]; then
	_ARCH_SPECS="\n*link_emulation:\nelf_i386\n\n*dynamic_linker:\n/system/bin/linker\n"
	TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" --with-arch=i686 --with-fpmath=sse "
elif [ "$TERMUX_ARCH" = "x86_64" ]; then
	TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" --with-arch=x86-64 --with-fpmath=sse"
fi

source $TERMUX_SCRIPTDIR/common-files/toolchain/setup_toolchain_gcc.sh

termux_pkg_auto_update() {
	local major="${TERMUX_PKG_VERSION%%.*}"
	local latest
	latest="$(
		curl --fail --silent --location --retry 3 \
			"https://mirrors.kernel.org/gnu/gcc/" |
			grep -oE "gcc-${major}\\.[0-9]+\\.0/" |
			sed -E 's|^gcc-||; s|/$||' |
			sort -V |
			tail -n1
	)" || termux_error_exit "failed to query GCC releases from mirrors.kernel.org"
	if [[ -z "${latest}" ]]; then
		termux_error_exit "failed to find latest GCC ${major} release"
	fi

	local prebuilt_json="$TERMUX_SCRIPTDIR/common-files/toolchain/prebuilt-gcc.json"
	local prebuilt_version
	prebuilt_version="$(jq -r --arg major "$major" '.[$major].version // empty' "$prebuilt_json")"
	if [[ "${prebuilt_version}" != "${latest}" ]]; then
		termux_error_exit "prebuilt GCC ${major} toolchain ${latest} is not in common-files/prebuilt-gcc.json (found: ${prebuilt_version:-none})"
	fi
	termux_pkg_upgrade_version "${latest}"
}

termux_step_pre_configure() {
	export ac_cv_func_aligned_alloc=no
	export ac_cv_func__aligned_malloc=no
	export ac_cv_func_memalign=no
	export ac_cv_c_bigendian=no

	_setup_toolchain_ndk_gcc_15

	# Explicitly define __BIONIC__ and __ANDROID__API__
	CFLAGS+=" -D__BIONIC__ -D__ANDROID_API__=$TERMUX_PKG_API_LEVEL"
	CPPFLAGS+=" -D__BIONIC__ -D__ANDROID_API__=$TERMUX_PKG_API_LEVEL"
	CXXFLAGS+=" -D__BIONIC__ -D__ANDROID_API__=$TERMUX_PKG_API_LEVEL"
	FCFLAGS=" -D__ANDROID_API__=$TERMUX_PKG_API_LEVEL"

	# Add the specs file
	sed "s|@TERMUX_PREFIX@|$TERMUX_PREFIX|g" $TERMUX_PKG_BUILDER_DIR/specs.in |
		sed "s|@TERMUX_HOST_PLATFORM@|$TERMUX_HOST_PLATFORM|g" |
		sed "s|@TERMUX_PKG_VERSION@|$TERMUX_PKG_VERSION|g" |
		sed "s|@ARCH_PLACEHOLDER@|$_ARCH_SPECS|g" > $TERMUX_PKG_TMPDIR/specs
	TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" --with-stage1-ldflags=\"-specs=$TERMUX_PKG_TMPDIR/specs\""

	# Add host and target flag
	TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" --host=$TERMUX_HOST_PLATFORM --target=$TERMUX_HOST_PLATFORM"
}

termux_step_post_make_install() {
	# GCC searches $PREFIX/$TERMUX_HOST_PLATFORM/include, so just make a symlink
	mkdir -p $TERMUX_PREFIX/$TERMUX_HOST_PLATFORM/include
	ln -sfr $TERMUX_PREFIX/include/$TERMUX_HOST_PLATFORM/asm $TERMUX_PREFIX/$TERMUX_HOST_PLATFORM/include/
	# Copy the build spec file
	cp $TERMUX_PKG_TMPDIR/specs $TERMUX_PREFIX/lib/gcc/$TERMUX_HOST_PLATFORM/$TERMUX_PKG_VERSION/
	# Avoid extract `ndk-sysroot-gcc-compact` at building time.
	TERMUX_PKG_DEPENDS+=", ndk-sysroot-gcc-compact (>= 27b-3)"
}

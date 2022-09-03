TERMUX_PKG_HOMEPAGE=http://gcc.gnu.org/
TERMUX_PKG_DESCRIPTION="GNU C compiler"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_DEPENDS="binutils, libc++, libgmp, libmpfr, libmpc, libisl, zlib"
TERMUX_PKG_VERSION=12.1.0
TERMUX_PKG_REVISION=1
TERMUX_PKG_MAINTAINER="@licy183"
TERMUX_PKG_SRCURL=https://ftp.gnu.org/gnu/gcc/gcc-${TERMUX_PKG_VERSION}/gcc-${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=e88a004a14697bbbaba311f38a938c716d9a652fd151aaaa4cf1b5b99b90e2de
TERMUX_PKG_BREAKS="binutils-is-llvm"
TERMUX_PKG_NO_STATICSPLIT=true
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
--with-libatomic
--with-system-zlib
--with-gmp=$TERMUX_PREFIX
--with-mpfr=$TERMUX_PREFIX
--with-mpc=$TERMUX_PREFIX
--with-isl=$TERMUX_PREFIX
--with-gxx-include-dir=$TERMUX_PREFIX/include/c++/v1
--program-suffix=-12
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

source $TERMUX_SCRIPTDIR/common-files/setup_toolchain_ndk_r17c.sh

termux_step_pre_configure() {
	if $TERMUX_ON_DEVICE_BUILD; then
		termux_error_exit "Package '$TERMUX_PKG_NAME' is not available for on-device builds."
	fi

	export ac_cv_func_aligned_alloc=no
	export ac_cv_func__aligned_malloc=no
	export ac_cv_func_memalign=no
	export ac_cv_c_bigendian=no

	_setup_toolchain_ndk_r17c_gcc_12

	# Add the specs file
	sed "s|@TERMUX_PREFIX@|$TERMUX_PREFIX|g" $TERMUX_PKG_BUILDER_DIR/specs.in |
		sed "s|@TERMUX_HOST_PLATFORM@|$TERMUX_HOST_PLATFORM|g" |
		sed "s|@TERMUX_PKG_VERSION@|$TERMUX_PKG_VERSION|g" |
		sed "s|@ARCH_PLACEHOLDER@|$_ARCH_SPECS|g" > $TERMUX_PKG_TMPDIR/specs
	TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" --with-stage1-ldflags=\"-specs=$TERMUX_PKG_TMPDIR/specs\""

	# Add host and target flag
	TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" --host=$TERMUX_HOST_PLATFORM --target=$TERMUX_HOST_PLATFORM"

	# Dummpy an INPUT script for libstdc++.so when building for arm.
	if [ "$TERMUX_ARCH" = "arm" ]; then
		echo "INPUT(-lc++_shared)" > $TERMUX_PREFIX/lib/libstdc++.so
	fi
}

termux_step_post_make_install() {
	# Delete the dummy INPUT script
	if [ "$TERMUX_ARCH" = "arm" ]; then
		rm -f $TERMUX_PREFIX/lib/libstdc++.so
	fi
	# GCC searches $PREFIX/$TERMUX_HOST_PLATFORM/include, so just make a symlink
	mkdir -p $TERMUX_PREFIX/$TERMUX_HOST_PLATFORM/include
	ln -sfr $TERMUX_PREFIX/include/$TERMUX_HOST_PLATFORM/asm $TERMUX_PREFIX/$TERMUX_HOST_PLATFORM/include/
	# Copy the build spec file
	cp $TERMUX_PKG_TMPDIR/specs $TERMUX_PREFIX/lib/gcc/$TERMUX_HOST_PLATFORM/$TERMUX_PKG_VERSION/
	# XXX: This is pretty hacking anyway, but I cannot find a better solution. 
	# XXX: `ndk-sysroot` has a different version of Android headers (like 23c)
	# XXX: but our custom toolchain should use the Android headers versioning 17c.
	# XXX: Another way to solve this issue is adding `ndk-sysroot-gcc-compact` to
	# XXX: `TERMUX_PKG_RECOMMENDS`, but that would break `gcc` if someone installs
	# XXX: `ndk-sysroot-gcc-compact` and `gcc`, and then install `ndk-sysroot` manually.
	TERMUX_PKG_DEPENDS+=", ndk-sysroot-gcc-compact"
}

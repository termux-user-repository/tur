TERMUX_PKG_HOMEPAGE=http://gcc.gnu.org/
TERMUX_PKG_DESCRIPTION="GNU C compiler"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_DEPENDS="binutils, libc++, libgmp, libmpfr, libmpc, libisl, zlib"
TERMUX_PKG_VERSION=11.3.0
TERMUX_PKG_REVISION=2
TERMUX_PKG_MAINTAINER="@licy183"
TERMUX_PKG_SRCURL=https://ftp.gnu.org/gnu/gcc/gcc-${TERMUX_PKG_VERSION}/gcc-${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=98438e6cc7294298b474cf0da7655d9a8c8b796421bb0210531c294a950374ed
TERMUX_PKG_BREAKS="binutils-is-llvm"
TERMUX_PKG_NO_STATICSPLIT=true
TERMUX_PKG_HOSTBUILD=true
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
--program-suffix=-11
"

TERMUX_PKG_RM_AFTER_INSTALL="
share/info
share/man/man7
"

_EXTRA_HOST_BUILD=""
_ARCH_SPECS=""

if [ "$TERMUX_ARCH" = "arm" ]; then
	_EXTRA_HOST_BUILD="--with-arch=armv7-a --with-float=soft --with-fpu=vfp"
elif [ "$TERMUX_ARCH" = "aarch64" ]; then
	_ARCH_SPECS="\n*cc1:\n+ -ffixed-x18\n\n*cc1plus:\n+ -ffixed-x18\n"
	_EXTRA_HOST_BUILD="--enable-fix-cortex-a53-835769 --enable-fix-cortex-a53-843419"
elif [ "$TERMUX_ARCH" = "i686" ]; then
	_ARCH_SPECS="\n*link_emulation:\nelf_i386\n\n*dynamic_linker:\n/system/bin/linker\n"
	_EXTRA_HOST_BUILD="--with-arch=i686 --with-fpmath=sse "
elif [ "$TERMUX_ARCH" = "x86_64" ]; then
	_EXTRA_HOST_BUILD="--with-arch=x86-64 --with-fpmath=sse"
fi

TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" $_EXTRA_HOST_BUILD"

if $TERMUX_ON_DEVICE_BUILD; then
	termux_error_exit "Package '$TERMUX_PKG_NAME' is not available for on-device builds."
fi

source $TERMUX_SCRIPTDIR/common-files/setup_toolchain_ndk_r17c.sh

termux_step_host_build() {
	if [ -f $TERMUX_PKG_CACHEDIR/.placeholder-newer-toolchain-$TERMUX_ARCH ]; then
		ln -sr $TERMUX_PKG_CACHEDIR/newer-toolchain-$TERMUX_ARCH $TERMUX_PKG_HOSTBUILD_DIR/newer-toolchain
		return
	fi

	# XXX: Install some build dependencies
	# XXX: So should TUR use a custom builder image?
	env -i PATH="$PATH" sudo apt update
	env -i PATH="$PATH" sudo apt install -y libgmp-dev libmpfr-dev libmpc-dev zlib1g-dev libisl-dev libtinfo5 libncurses5

	# Setup a standalone toolchain
	_setup_standalone_toolchain_ndk_r17c $TERMUX_PKG_HOSTBUILD_DIR/standalone-toolchain
	cp -R ./standalone-toolchain/sysroot/usr/include/$TERMUX_HOST_PLATFORM/* ./standalone-toolchain/sysroot/usr/include/

	_OLD_PATH="$PATH"
	PATH="$TERMUX_PKG_HOSTBUILD_DIR/standalone-toolchain/bin:$PATH"

	# Build a custom toolchain
	mkdir -p newer-toolchain
	cp -R ./standalone-toolchain/sysroot ./newer-toolchain/

	mkdir -p newer-toolchain-build
	pushd newer-toolchain-build

	export CFLAGS="-D__ANDROID_API__=$TERMUX_PKG_API_LEVEL"
	export CPPFLAGS="-D__ANDROID_API__=$TERMUX_PKG_API_LEVEL"
	export CXXFLAGS="-D__ANDROID_API__=$TERMUX_PKG_API_LEVEL"

	$TERMUX_PKG_SRCDIR/configure \
				--host=x86_64-linux-gnu  \
				--build=x86_64-linux-gnu \
				--target=$TERMUX_HOST_PLATFORM \
				--disable-shared \
				--disable-nls \
				--enable-default-pie \
				--with-host-libstdcxx='-static-libgcc -Wl,-Bstatic,-lstdc++,-Bdynamic -lm' \
				--with-gnu-as --with-gnu-ld \
				--disable-libstdc__-v3 \
				--disable-tls \
				--disable-bootstrap \
				--enable-initfini-array \
				--enable-libatomic-ifuncs=no \
				--prefix=$TERMUX_PKG_HOSTBUILD_DIR/newer-toolchain \
				--with-gmp --with-mpfr --with-mpc --with-system-zlib \
				--enable-languages=c,c++,fortran \
				--enable-plugins --enable-libgomp \
				--enable-gnu-indirect-function \
				--disable-libcilkrts --disable-libsanitizer \
				--enable-gold --enable-threads \
				--enable-eh-frame-hdr-for-static \
				--enable-graphite=yes --with-isl \
				--disable-multilib \
				$_EXTRA_HOST_BUILD \
				--with-sysroot=$TERMUX_PKG_HOSTBUILD_DIR/newer-toolchain/sysroot \
				--with-gxx-include-dir=$TERMUX_PKG_HOSTBUILD_DIR/newer-toolchain/include/c++/$TERMUX_PKG_VERSION
	
	make -j $TERMUX_MAKE_PROCESSES
	make -j $TERMUX_MAKE_PROCESSES install
	popd

	PATH="$_OLD_PATH"

	# Move the pre-built toolchain to $TERMUX_PKG_CACHEDIR and touch a placeholder
	rm -rf $TERMUX_PKG_CACHEDIR/newer-toolchain-$TERMUX_ARCH
	mv $TERMUX_PKG_HOSTBUILD_DIR/newer-toolchain $TERMUX_PKG_CACHEDIR/newer-toolchain-$TERMUX_ARCH
	ln -sr $TERMUX_PKG_CACHEDIR/newer-toolchain-$TERMUX_ARCH $TERMUX_PKG_HOSTBUILD_DIR/newer-toolchain
	touch $TERMUX_PKG_CACHEDIR/.placeholder-newer-toolchain-$TERMUX_ARCH
}

termux_step_pre_configure() {
	# XXX: Remove this all the time, as toolchian is architecture-specific.
	rm -rf $TERMUX_HOSTBUILD_MARKER

	export ac_cv_func_aligned_alloc=no
	export ac_cv_func__aligned_malloc=no
	export ac_cv_func_memalign=no
	export ac_cv_c_bigendian=no

	export OLD_NDK_TOOLCHAIN=$TERMUX_PKG_TMPDIR/android-ndk-r17c-$TERMUX_ARCH
	_setup_toolchain_ndk_r17c $OLD_NDK_TOOLCHAIN

	# Merge toolchain
	cp -R $TERMUX_PKG_CACHEDIR/newer-toolchain-$TERMUX_ARCH/* $OLD_NDK_TOOLCHAIN/
	mv $OLD_NDK_TOOLCHAIN/include/c++/4.9.x $OLD_NDK_TOOLCHAIN/include/c++/$TERMUX_PKG_VERSION
	export FC=$TERMUX_HOST_PLATFORM-gfortran

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

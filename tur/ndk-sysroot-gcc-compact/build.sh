TERMUX_PKG_HOMEPAGE=https://developer.android.com/tools/sdk/ndk/index.html
TERMUX_PKG_DESCRIPTION="System header and library files from the Android NDK needed for compiling C programs, compact with GNU Compiler Collection"
TERMUX_PKG_LICENSE="NCSA"
TERMUX_PKG_MAINTAINER="@licy183"
TERMUX_PKG_VERSION=$TERMUX_NDK_VERSION
TERMUX_PKG_SKIP_SRC_EXTRACT=true
# This package has taken over <pty.h> from the previous libutil-dev
# and iconv.h from libandroid-support-dev:
TERMUX_PKG_CONFLICTS="libutil-dev, libandroid-support-dev, ndk-sysroot"
TERMUX_PKG_REPLACES="libutil-dev, libandroid-support-dev, ndk-stl, ndk-sysroot"
TERMUX_PKG_PROVIDES="ndk-sysroot"
TERMUX_PKG_NO_STATICSPLIT=true

termux_step_extract_into_massagedir() {
	mkdir -p $TERMUX_PKG_MASSAGEDIR/$TERMUX_PREFIX/lib \
		$TERMUX_PKG_MASSAGEDIR/$TERMUX_PREFIX/include

	cp -Rf $TERMUX_STANDALONE_TOOLCHAIN/sysroot/usr/include/* \
		$TERMUX_PKG_MASSAGEDIR/$TERMUX_PREFIX/include

	# replace vulkan headers with upstream version
	rm -rf $TERMUX_PKG_MASSAGEDIR/$TERMUX_PREFIX/include/vulkan

	# Apply patches
	# TODO: Currently, we don't support fortify for gcc, but may add it later.
	for f in $(find "$TERMUX_PKG_BUILDER_DIR/" -maxdepth 1 -type f -name *.diff | sort); do
		echo "Applying patch: $(basename $f)"
		patch -d "$TERMUX_PKG_MASSAGEDIR/$TERMUX_PREFIX/include/" -p1 < "$f";
		# sed "s%\@TERMUX_PREFIX\@%${TERMUX_PREFIX}%g" "$f" | \
		# 	sed "s%\@TERMUX_HOME\@%${TERMUX_ANDROID_HOME}%g" | \
		# 	patch --silent -p1;
	done
	# patch -d $TERMUX_PKG_MASSAGEDIR/$TERMUX_PREFIX/include/  -p1 < $TERMUX_PKG_BUILDER_DIR/0001-c++-v1-math-headers.diff
	# patch -d $TERMUX_PKG_MASSAGEDIR/$TERMUX_PREFIX/include/  -p1 < $TERMUX_PKG_BUILDER_DIR/0002-android-versioning.h.diff
	# patch -d $TERMUX_PKG_MASSAGEDIR/$TERMUX_PREFIX/include/  -p1 < $TERMUX_PKG_BUILDER_DIR/0003-sys-cdefs.h.diff
	# patch -d $TERMUX_PKG_MASSAGEDIR/$TERMUX_PREFIX/include/  -p1 < $TERMUX_PKG_BUILDER_DIR/0004-compact-with-clang-builtins.diff

	cp $TERMUX_STANDALONE_TOOLCHAIN/sysroot/usr/lib/$TERMUX_HOST_PLATFORM/$TERMUX_PKG_API_LEVEL/*.o \
		$TERMUX_PKG_MASSAGEDIR/$TERMUX_PREFIX/lib

	if [ $TERMUX_ARCH == "i686" ]; then
		LIBATOMIC=$NDK/toolchains/llvm/prebuilt/linux-x86_64/lib64/clang/*/lib/linux/i386
	elif [ $TERMUX_ARCH == "arm64" ]; then
		LIBATOMIC=$NDK/toolchains/llvm/prebuilt/linux-x86_64/lib64/clang/*/lib/linux/aarch64
	else
		LIBATOMIC=$NDK/toolchains/llvm/prebuilt/linux-x86_64/lib64/clang/*/lib/linux/$TERMUX_ARCH
	fi

	cp $LIBATOMIC/libatomic.a $TERMUX_PKG_MASSAGEDIR/$TERMUX_PREFIX/lib/

	cp $TERMUX_STANDALONE_TOOLCHAIN/sysroot/usr/lib/$TERMUX_HOST_PLATFORM/$TERMUX_PKG_API_LEVEL/libcompiler_rt-extras.a $TERMUX_PKG_MASSAGEDIR/$TERMUX_PREFIX/lib/
	# librt and libpthread are built into libc on android, so setup them as symlinks
	# to libc for compatibility with programs that users try to build:
	local _SYSTEM_LIBDIR=/system/lib64
	if [ $TERMUX_ARCH_BITS = 32 ]; then _SYSTEM_LIBDIR=/system/lib; fi
	mkdir -p $TERMUX_PKG_MASSAGEDIR/$TERMUX_PREFIX/lib
	cd $TERMUX_PKG_MASSAGEDIR/$TERMUX_PREFIX/lib
	NDK_ARCH=$TERMUX_ARCH
	test $NDK_ARCH == 'i686' && NDK_ARCH='i386'
	# clang 13 requires libunwind on Android.
	cp $TERMUX_STANDALONE_TOOLCHAIN/lib64/clang/12.0.9/lib/linux/$NDK_ARCH/libunwind.a .

	for lib in librt.so libpthread.so libutil.so; do
		echo 'INPUT(-lc)' > $TERMUX_PKG_MASSAGEDIR/$TERMUX_PREFIX/lib/$lib
	done
	unset lib
}

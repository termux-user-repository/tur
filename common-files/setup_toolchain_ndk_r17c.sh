_download_ndk_r17c() {
	if [ ! -f $TERMUX_COMMON_CACHEDIR/older-ndk/.placeholder-android-ndk-r17c ]; then
		echo "Start downloading Android NDK toolchain (version r17c)..."
		mkdir -p $TERMUX_COMMON_CACHEDIR/older-ndk/
		local _NDK_ARCHIVE_FILE=$TERMUX_COMMON_CACHEDIR/older-ndk/android-ndk-r17c-linux-x86_64.zip
		local _NDK_URL=https://dl.google.com/android/repository/android-ndk-r17c-linux-x86_64.zip
		local _NDK_SHA256=3f541adbd0330a9205ba12697f6d04ec90752c53d6b622101a2a8a856e816589
		termux_download $_NDK_URL $_NDK_ARCHIVE_FILE $_NDK_SHA256
		unzip -d $TERMUX_COMMON_CACHEDIR/older-ndk/ $_NDK_ARCHIVE_FILE > /dev/null 2>&1
		touch $TERMUX_COMMON_CACHEDIR/older-ndk/.placeholder-android-ndk-r17c
		echo "Downloading completed."
	fi
}

_setup_standalone_toolchain_ndk_r17c() {
	_download_ndk_r17c

	local TOOLCHAIN_DIR="$1"
	rm -rf $TOOLCHAIN_DIR

	local _NDK_ARCH
	if [ "$TERMUX_ARCH" == "aarch64" ]; then
		_NDK_ARCH="arm64"
	elif [ "$TERMUX_ARCH" == "arm" ]; then
		_NDK_ARCH="arm"
	elif [ "$TERMUX_ARCH" == "x86_64" ]; then
		_NDK_ARCH="x86_64"
	elif [ "$TERMUX_ARCH" == "i686" ]; then
		_NDK_ARCH="x86"
	fi

	# Setup a standalone toolchain
	python $TERMUX_COMMON_CACHEDIR/older-ndk/android-ndk-r17c/build/tools/make_standalone_toolchain.py \
				--arch $_NDK_ARCH --api $TERMUX_PKG_API_LEVEL --install-dir $TOOLCHAIN_DIR

	# Modify sysroot
	pushd $TOOLCHAIN_DIR

	# See https://github.com/android/ndk/issues/215#issuecomment-524293090
	sed -i "s/include_next <stddef.h>/include <stddef.h>/" include/c++/4.9.x/cstddef

	cd $TOOLCHAIN_DIR/sysroot

	# Apply patches
	for f in $TERMUX_SCRIPTDIR/common-files/ndk-patches/r17c/*.patch; do
		echo "Applying ndk-patch: $(basename $f)"
		sed "s%\@TERMUX_PREFIX\@%${TERMUX_PREFIX}%g" "$f" | \
			sed "s%\@TERMUX_HOME\@%${TERMUX_ANDROID_HOME}%g" | \
			patch --silent -p1;
	done

	# libintl.h: Inline implementation gettext functions.
	# langinfo.h: Inline implementation of nl_langinfo().
	cp "$TERMUX_SCRIPTDIR"/ndk-patches/{libintl.h,langinfo.h} usr/include

	# Remove <sys/capability.h> because it is provided by libcap.
	# Remove <sys/shm.h> from the NDK in favour of that from the libandroid-shmem.
	# Remove <sys/sem.h> as it doesn't work for non-root.
	# Remove <glob.h> as we currently provide it from libandroid-glob.
	# Remove <iconv.h> as it's provided by libiconv.
	# Remove <zlib.h> and <zconf.h> as we build our own zlib.
	# Remove KRH/khrplatform.h provided by mesa.
	rm usr/include/{sys/{capability,shm,sem},{glob,iconv,zlib,zconf},KHR/khrplatform}.h

	sed -i "s/define __ANDROID_API__ __ANDROID_API_FUTURE__/define __ANDROID_API__ $TERMUX_PKG_API_LEVEL/" \
		usr/include/android/api-level.h
	popd
}

_setup_toolchain_ndk_r17c_envs() {
	source $TERMUX_SCRIPTDIR/common-files/setup_toolchain_gcc.sh
	_setup_toolchain_gcc_envs
}

_setup_toolchain_ndk_r17c_envs_with_fc() {
	source $TERMUX_SCRIPTDIR/common-files/setup_toolchain_gcc.sh
	_setup_toolchain_gcc_envs_with_fc
}

_setup_toolchain_ndk_r17c() {
	GCC_STANDALONE_TOOLCHAIN="$TERMUX_COMMON_CACHEDIR/android-r17c-api-${TERMUX_PKG_API_LEVEL}-$TERMUX_HOST_PLATFORM-gcc-4.9"
	GCC_STANDALONE_TOOLCHAIN+="-v0"

	_setup_toolchain_ndk_r17c_envs

	if [ "$TERMUX_ON_DEVICE_BUILD" = "true" ] || [ -d $GCC_STANDALONE_TOOLCHAIN ]; then
		return
	fi

	local GCC_STANDALONE_TOOLCHAIN_TMP="$GCC_STANDALONE_TOOLCHAIN"-tmp

	# Setup a standalone toolchain
	_setup_standalone_toolchain_ndk_r17c "$GCC_STANDALONE_TOOLCHAIN_TMP"

	mv $GCC_STANDALONE_TOOLCHAIN_TMP $GCC_STANDALONE_TOOLCHAIN
}

_setup_standalone_toolchain_ndk_r17c_newer_gcc() {
	if [ "$TERMUX_ON_DEVICE_BUILD" = "true" ]; then
		termux_error_exit "NDK toolchain r17c with newer gcc is not available for on-device builds."
	fi

	# XXX: Install some build dependencies
	# XXX: So should TUR use a custom builder image?
	env -i PATH="$PATH" sudo apt update
	env -i PATH="$PATH" sudo apt install -y libgmp-dev libmpfr-dev libmpc-dev zlib1g-dev libisl-dev libtinfo5 libncurses5

	local GCC_VERSION="$1"
	local GCC_TOOLCHAIN_REVISION="$2"
	local GCC_PREBUILT_SHA256="$3"
	local GCC_TOOLCHAIN_VERSION="$4"

	local GCC_PREBUILT_URL=https://github.com/termux-user-repository/ndk-toolchain-gcc-${GCC_VERSION%%.*}/releases/download/v$GCC_VERSION-r$GCC_TOOLCHAIN_REVISION/gcc-$GCC_VERSION-$TERMUX_ARCH.tar.bz2
	local GCC_PREBUILT_FILE=$TERMUX_COMMON_CACHEDIR/gcc-$GCC_VERSION-r$GCC_TOOLCHAIN_REVISION-$TERMUX_ARCH.tar.bz2
	termux_download $GCC_PREBUILT_URL $GCC_PREBUILT_FILE $GCC_PREBUILT_SHA256

	GCC_STANDALONE_TOOLCHAIN="$TERMUX_COMMON_CACHEDIR/android-r17c-api-${TERMUX_PKG_API_LEVEL}-$TERMUX_HOST_PLATFORM-gcc-$GCC_VERSION-r$GCC_TOOLCHAIN_REVISION-v$GCC_TOOLCHAIN_VERSION"

	if ! [ -d $GCC_STANDALONE_TOOLCHAIN ]; then
		local GCC_STANDALONE_TOOLCHAIN_TMP="$GCC_STANDALONE_TOOLCHAIN"-tmp

		# Setup a standalone toolchain
		_setup_standalone_toolchain_ndk_r17c "$GCC_STANDALONE_TOOLCHAIN_TMP"

		# Merge toolchain
		tar -jxf $GCC_PREBUILT_FILE -C $TERMUX_PKG_TMPDIR
		rm -rf $TERMUX_PKG_TMPDIR/gcc-$GCC_VERSION-$TERMUX_ARCH/sysroot
		cp -R $TERMUX_PKG_TMPDIR/gcc-$GCC_VERSION-$TERMUX_ARCH/* $GCC_STANDALONE_TOOLCHAIN_TMP/
		rm -rf $TERMUX_PKG_TMPDIR/gcc-$GCC_VERSION-$TERMUX_ARCH
		mv $GCC_STANDALONE_TOOLCHAIN_TMP/include/c++/4.9.x $GCC_STANDALONE_TOOLCHAIN_TMP/include/c++/$GCC_VERSION
		cp -R $GCC_STANDALONE_TOOLCHAIN_TMP/sysroot/usr/include/$TERMUX_HOST_PLATFORM/* $GCC_STANDALONE_TOOLCHAIN_TMP/sysroot/usr/include/

		# Remove the older version of clang toolchain
		rm -rf $GCC_STANDALONE_TOOLCHAIN_TMP/bin/clang*
		rm -rf $GCC_STANDALONE_TOOLCHAIN_TMP/bin/llvm*
		rm -rf $GCC_STANDALONE_TOOLCHAIN_TMP/bin/$TERMUX_HOST_PLATFORM-clang*
		rm -rf $GCC_STANDALONE_TOOLCHAIN_TMP/bin/$TERMUX_HOST_PLATFORM-gcc-4.9*

		mv $GCC_STANDALONE_TOOLCHAIN_TMP $GCC_STANDALONE_TOOLCHAIN
	fi
}

_setup_toolchain_ndk_r17c_gcc_11() {
	local GCC_TOOLCHAIN_VERSION=0

    local PREBUILT_GCC_JSON="$TERMUX_SCRIPTDIR/common-files/prebuilt-gcc.json"
	local GCC_VERSION=$(jq -r '.["11"].version' $PREBUILT_GCC_JSON)
	local GCC_TOOLCHAIN_REVISION=$(jq -r '.["11"].revision' $PREBUILT_GCC_JSON)
	local GCC_PREBUILT_SHA256=$(jq -r ".[\"11\"].checksums.$TERMUX_ARCH" $PREBUILT_GCC_JSON)

	_setup_standalone_toolchain_ndk_r17c_newer_gcc "$GCC_VERSION" "$GCC_TOOLCHAIN_REVISION" "$GCC_PREBUILT_SHA256" "$GCC_TOOLCHAIN_VERSION"
	_setup_toolchain_ndk_r17c_envs_with_fc
}

_setup_toolchain_ndk_r17c_gcc_10() {
	local GCC_TOOLCHAIN_VERSION=0

    local PREBUILT_GCC_JSON="$TERMUX_SCRIPTDIR/common-files/prebuilt-gcc.json"
	local GCC_VERSION=$(jq -r '.["10"].version' $PREBUILT_GCC_JSON)
	local GCC_TOOLCHAIN_REVISION=$(jq -r '.["10"].revision' $PREBUILT_GCC_JSON)
	local GCC_PREBUILT_SHA256=$(jq -r ".[\"10\"].checksums.$TERMUX_ARCH" $PREBUILT_GCC_JSON)

	_setup_standalone_toolchain_ndk_r17c_newer_gcc "$GCC_VERSION" "$GCC_TOOLCHAIN_REVISION" "$GCC_PREBUILT_SHA256" "$GCC_TOOLCHAIN_VERSION"
	_setup_toolchain_ndk_r17c_envs_with_fc
}

_setup_toolchain_ndk_r17c_gcc_9() {
	local GCC_TOOLCHAIN_VERSION=0

    local PREBUILT_GCC_JSON="$TERMUX_SCRIPTDIR/common-files/prebuilt-gcc.json"
	local GCC_VERSION=$(jq -r '.["9"].version' $PREBUILT_GCC_JSON)
	local GCC_TOOLCHAIN_REVISION=$(jq -r '.["9"].revision' $PREBUILT_GCC_JSON)
	local GCC_PREBUILT_SHA256=$(jq -r ".[\"9\"].checksums.$TERMUX_ARCH" $PREBUILT_GCC_JSON)

	_setup_standalone_toolchain_ndk_r17c_newer_gcc "$GCC_VERSION" "$GCC_TOOLCHAIN_REVISION" "$GCC_PREBUILT_SHA256" "$GCC_TOOLCHAIN_VERSION"
	_setup_toolchain_ndk_r17c_envs_with_fc
}

_setup_toolchain_ndk_r17c_gcc_12() {
	local GCC_TOOLCHAIN_VERSION=0

    local PREBUILT_GCC_JSON="$TERMUX_SCRIPTDIR/common-files/prebuilt-gcc.json"
	local GCC_VERSION=$(jq -r '.["12"].version' $PREBUILT_GCC_JSON)
	local GCC_TOOLCHAIN_REVISION=$(jq -r '.["12"].revision' $PREBUILT_GCC_JSON)
	local GCC_PREBUILT_SHA256=$(jq -r ".[\"12\"].checksums.$TERMUX_ARCH" $PREBUILT_GCC_JSON)

	_setup_standalone_toolchain_ndk_r17c_newer_gcc "$GCC_VERSION" "$GCC_TOOLCHAIN_REVISION" "$GCC_PREBUILT_SHA256" "$GCC_TOOLCHAIN_VERSION"
	_setup_toolchain_ndk_r17c_envs_with_fc
}

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

    local PREBUILT_GCC_JSON="$TERMUX_SCRIPTDIR/common-files/toolchain/deprecated/prebuilt-gcc.json"
	local GCC_VERSION=$(jq -r '.["11"].version' $PREBUILT_GCC_JSON)
	local GCC_TOOLCHAIN_REVISION=$(jq -r '.["11"].revision' $PREBUILT_GCC_JSON)
	local GCC_PREBUILT_SHA256=$(jq -r ".[\"11\"].checksums.$TERMUX_ARCH" $PREBUILT_GCC_JSON)

	_setup_standalone_toolchain_ndk_r17c_newer_gcc "$GCC_VERSION" "$GCC_TOOLCHAIN_REVISION" "$GCC_PREBUILT_SHA256" "$GCC_TOOLCHAIN_VERSION"
	_setup_toolchain_ndk_r17c_envs_with_fc
}

_setup_toolchain_ndk_r17c_gcc_10() {
	local GCC_TOOLCHAIN_VERSION=0

    local PREBUILT_GCC_JSON="$TERMUX_SCRIPTDIR/common-files/toolchain/deprecated/prebuilt-gcc.json"
	local GCC_VERSION=$(jq -r '.["10"].version' $PREBUILT_GCC_JSON)
	local GCC_TOOLCHAIN_REVISION=$(jq -r '.["10"].revision' $PREBUILT_GCC_JSON)
	local GCC_PREBUILT_SHA256=$(jq -r ".[\"10\"].checksums.$TERMUX_ARCH" $PREBUILT_GCC_JSON)

	_setup_standalone_toolchain_ndk_r17c_newer_gcc "$GCC_VERSION" "$GCC_TOOLCHAIN_REVISION" "$GCC_PREBUILT_SHA256" "$GCC_TOOLCHAIN_VERSION"
	_setup_toolchain_ndk_r17c_envs_with_fc
}

_setup_toolchain_ndk_r17c_gcc_9() {
	local GCC_TOOLCHAIN_VERSION=0

    local PREBUILT_GCC_JSON="$TERMUX_SCRIPTDIR/common-files/toolchain/deprecated/prebuilt-gcc.json"
	local GCC_VERSION=$(jq -r '.["9"].version' $PREBUILT_GCC_JSON)
	local GCC_TOOLCHAIN_REVISION=$(jq -r '.["9"].revision' $PREBUILT_GCC_JSON)
	local GCC_PREBUILT_SHA256=$(jq -r ".[\"9\"].checksums.$TERMUX_ARCH" $PREBUILT_GCC_JSON)

	_setup_standalone_toolchain_ndk_r17c_newer_gcc "$GCC_VERSION" "$GCC_TOOLCHAIN_REVISION" "$GCC_PREBUILT_SHA256" "$GCC_TOOLCHAIN_VERSION"
	_setup_toolchain_ndk_r17c_envs_with_fc
}

_setup_toolchain_ndk_r17c_gcc_12() {
	local GCC_TOOLCHAIN_VERSION=0

    local PREBUILT_GCC_JSON="$TERMUX_SCRIPTDIR/common-files/toolchain/deprecated/prebuilt-gcc.json"
	local GCC_VERSION=$(jq -r '.["12"].version' $PREBUILT_GCC_JSON)
	local GCC_TOOLCHAIN_REVISION=$(jq -r '.["12"].revision' $PREBUILT_GCC_JSON)
	local GCC_PREBUILT_SHA256=$(jq -r ".[\"12\"].checksums.$TERMUX_ARCH" $PREBUILT_GCC_JSON)

	_setup_standalone_toolchain_ndk_r17c_newer_gcc "$GCC_VERSION" "$GCC_TOOLCHAIN_REVISION" "$GCC_PREBUILT_SHA256" "$GCC_TOOLCHAIN_VERSION"
	_setup_toolchain_ndk_r17c_envs_with_fc
}

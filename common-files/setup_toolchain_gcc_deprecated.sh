_setup_toolchain_ndk_gcc_9() {
	local GCC_TOOLCHAIN_VERSION=2

    local PREBUILT_GCC_JSON="$TERMUX_SCRIPTDIR/common-files/prebuilt-gcc.json"
	local GCC_VERSION=$(jq -r '.["9"].version' $PREBUILT_GCC_JSON)
	local GCC_TOOLCHAIN_REVISION=$(jq -r '.["9"].revision' $PREBUILT_GCC_JSON)
	local GCC_PREBUILT_SHA256=$(jq -r ".[\"9\"].checksums.$TERMUX_ARCH" $PREBUILT_GCC_JSON)

	_setup_standalone_toolchain_current_ndk_newer_gcc "$GCC_VERSION" "$GCC_TOOLCHAIN_REVISION" "$GCC_PREBUILT_SHA256" "$GCC_TOOLCHAIN_VERSION"
	_setup_toolchain_gcc_envs_with_fc
}

_setup_toolchain_ndk_gcc_10() {
	local GCC_TOOLCHAIN_VERSION=2

    local PREBUILT_GCC_JSON="$TERMUX_SCRIPTDIR/common-files/prebuilt-gcc.json"
	local GCC_VERSION=$(jq -r '.["10"].version' $PREBUILT_GCC_JSON)
	local GCC_TOOLCHAIN_REVISION=$(jq -r '.["10"].revision' $PREBUILT_GCC_JSON)
	local GCC_PREBUILT_SHA256=$(jq -r ".[\"10\"].checksums.$TERMUX_ARCH" $PREBUILT_GCC_JSON)

	_setup_standalone_toolchain_current_ndk_newer_gcc "$GCC_VERSION" "$GCC_TOOLCHAIN_REVISION" "$GCC_PREBUILT_SHA256" "$GCC_TOOLCHAIN_VERSION"
	_setup_toolchain_gcc_envs_with_fc
}

_setup_toolchain_ndk_with_gfortran_11() {
	local GCC_TOOLCHAIN_VERSION=2

    local PREBUILT_GCC_JSON="$TERMUX_SCRIPTDIR/common-files/prebuilt-gcc.json"
	local GCC_VERSION=$(jq -r '.["11"].version' $PREBUILT_GCC_JSON)
	local GCC_TOOLCHAIN_REVISION=$(jq -r '.["11"].revision' $PREBUILT_GCC_JSON)
	local GCC_PREBUILT_SHA256=$(jq -r ".[\"11\"].checksums.$TERMUX_ARCH" $PREBUILT_GCC_JSON)

	_setup_standalone_toolchain_current_ndk_newer_gcc "$GCC_VERSION" "$GCC_TOOLCHAIN_REVISION" "$GCC_PREBUILT_SHA256" "$GCC_TOOLCHAIN_VERSION"

	# Set FC
	export FC=$TERMUX_HOST_PLATFORM-gfortran
	export FCFLAGS=""

	# Explicitly define __BIONIC__ and __ANDROID__API__
	CFLAGS+=" -D__BIONIC__ -D__ANDROID_API__=$TERMUX_PKG_API_LEVEL"
	CPPFLAGS+=" -D__BIONIC__ -D__ANDROID_API__=$TERMUX_PKG_API_LEVEL"
	CXXFLAGS+=" -D__BIONIC__ -D__ANDROID_API__=$TERMUX_PKG_API_LEVEL"
	FCFLAGS+=" -D__ANDROID_API__=$TERMUX_PKG_API_LEVEL"

	export PATH="$PATH:$GCC_STANDALONE_TOOLCHAIN/bin"
}

_setup_toolchain_ndk_gcc_11() {
	local GCC_TOOLCHAIN_VERSION=2

    local PREBUILT_GCC_JSON="$TERMUX_SCRIPTDIR/common-files/prebuilt-gcc.json"
	local GCC_VERSION=$(jq -r '.["11"].version' $PREBUILT_GCC_JSON)
	local GCC_TOOLCHAIN_REVISION=$(jq -r '.["11"].revision' $PREBUILT_GCC_JSON)
	local GCC_PREBUILT_SHA256=$(jq -r ".[\"11\"].checksums.$TERMUX_ARCH" $PREBUILT_GCC_JSON)

	_setup_standalone_toolchain_current_ndk_newer_gcc "$GCC_VERSION" "$GCC_TOOLCHAIN_REVISION" "$GCC_PREBUILT_SHA256" "$GCC_TOOLCHAIN_VERSION"
	_setup_toolchain_gcc_envs_with_fc
}

_setup_toolchain_ndk_gcc_12() {
	local GCC_TOOLCHAIN_VERSION=2

    local PREBUILT_GCC_JSON="$TERMUX_SCRIPTDIR/common-files/prebuilt-gcc.json"
	local GCC_VERSION=$(jq -r '.["12"].version' $PREBUILT_GCC_JSON)
	local GCC_TOOLCHAIN_REVISION=$(jq -r '.["12"].revision' $PREBUILT_GCC_JSON)
	local GCC_PREBUILT_SHA256=$(jq -r ".[\"12\"].checksums.$TERMUX_ARCH" $PREBUILT_GCC_JSON)

	_setup_standalone_toolchain_current_ndk_newer_gcc "$GCC_VERSION" "$GCC_TOOLCHAIN_REVISION" "$GCC_PREBUILT_SHA256" "$GCC_TOOLCHAIN_VERSION"
	_setup_toolchain_gcc_envs_with_fc
}

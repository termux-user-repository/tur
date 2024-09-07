_setup_toolchain_ndk_gcc_10() {
	local GCC_TOOLCHAIN_VERSION=2

    local PREBUILT_GCC_JSON="$TERMUX_SCRIPTDIR/common-files/prebuilt-gcc.json"
	local GCC_VERSION=$(jq -r '.["10"].version' $PREBUILT_GCC_JSON)
	local GCC_TOOLCHAIN_REVISION=$(jq -r '.["10"].revision' $PREBUILT_GCC_JSON)
	local GCC_PREBUILT_SHA256=$(jq -r ".[\"10\"].checksums.$TERMUX_ARCH" $PREBUILT_GCC_JSON)

	_setup_standalone_toolchain_current_ndk_newer_gcc "$GCC_VERSION" "$GCC_TOOLCHAIN_REVISION" "$GCC_PREBUILT_SHA256" "$GCC_TOOLCHAIN_VERSION"
	_setup_toolchain_gcc_envs_with_fc
}

_setup_toolchain_ndk_gcc_9() {
	local GCC_TOOLCHAIN_VERSION=2

    local PREBUILT_GCC_JSON="$TERMUX_SCRIPTDIR/common-files/prebuilt-gcc.json"
	local GCC_VERSION=$(jq -r '.["9"].version' $PREBUILT_GCC_JSON)
	local GCC_TOOLCHAIN_REVISION=$(jq -r '.["9"].revision' $PREBUILT_GCC_JSON)
	local GCC_PREBUILT_SHA256=$(jq -r ".[\"9\"].checksums.$TERMUX_ARCH" $PREBUILT_GCC_JSON)

	_setup_standalone_toolchain_current_ndk_newer_gcc "$GCC_VERSION" "$GCC_TOOLCHAIN_REVISION" "$GCC_PREBUILT_SHA256" "$GCC_TOOLCHAIN_VERSION"
	_setup_toolchain_gcc_envs_with_fc
}

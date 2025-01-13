TERMUX_PKG_HOMEPAGE=https://github.com/TNTwise/rife-ncnn-vulkan
TERMUX_PKG_DESCRIPTION="TNTwise's fork of rife-ncnn-vulkan: RIFE, Real-Time Intermediate Flow Estimation for Video Frame Interpolation implemented with ncnn library"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="20250112"
TERMUX_PKG_SRCURL=git+https://github.com/TNTwise/rife-ncnn-vulkan
TERMUX_PKG_DEPENDS="libwebp"
TERMUX_PKG_BUILD_DEPENDS="vulkan-headers, vulkan-loader-android"
TERMUX_PKG_GIT_BRANCH="$TERMUX_PKG_VERSION"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_TAG_TYPE="newest-tag"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="-DUSE_SYSTEM_WEBP=ON"

termux_step_pre_configure() {
	LDFLAGS+=" -llog -landroid -fopenmp -static-openmp"

	local _RPATH_FLAG="-Wl,-rpath=$TERMUX_PREFIX/lib"
	local _RPATH_FLAG_ADD="-Wl,-rpath='\$ORIGIN' -Wl,-rpath=$TERMUX_PREFIX/lib"
	LDFLAGS="${LDFLAGS/$_RPATH_FLAG/$_RPATH_FLAG_ADD}"

	TERMUX_SRCDIR_SAVE=$TERMUX_PKG_SRCDIR
	TERMUX_PKG_SRCDIR=$TERMUX_PKG_SRCDIR/src
}

termux_step_post_configure() {
	TERMUX_PKG_SRCDIR=$TERMUX_SRCDIR_SAVE
	unset TERMUX_SRCDIR_SAVE
}

termux_step_make_install() {
	local install_prefix="$TERMUX_PREFIX/opt/$TERMUX_PKG_NAME"
	rm -rf "$install_prefix"
	mkdir -p "$install_prefix"

	# Install binary
	install -Dm700 rife-ncnn-vulkan "$install_prefix"
	ln -sfr $install_prefix/rife-ncnn-vulkan $TERMUX_PREFIX/bin/

	# Install the system libvulkan.so
	local system_lib="/system/lib"
	[[ "${TERMUX_ARCH_BITS}" == "64" ]] && system_lib+="64"
	system_lib+="/libvulkan.so"
	ln -sf "$system_lib" "$install_prefix/"

	# Install models
	cp -r $TERMUX_PKG_SRCDIR/models/rife-v2.3 "$install_prefix/rife-v2.3" # default value of model arg
	cp -r $TERMUX_PKG_SRCDIR/models/rife-v4.6 "$install_prefix/rife-v4.6" # nihui's repo latest model
	local max_ver=0.0
	local max_lite_ver=0.0
	local rife_dir ver
	for rife_dir in $TERMUX_PKG_SRCDIR/models/rife-v*; do
		ver=$(basename "$rife_dir")
		ver=${ver##rife-v}
		[ "${#ver}" -eq 1 ] && ver="$ver.0"
		if [ "${ver: -5}" == "-lite" ] && ver="${ver::-5}"; then
			[ "${ver::1}" == 4 ] && [ "${ver:2}" -ge "${max_lite_ver:2}" ] && max_lite_ver="$ver"
		elif [ "${ver::1}" == 4 ] && [ "${ver:2}" -ge "${max_ver:2}" ]; then
			max_ver="$ver"
		fi
	done
	if [ "$max_lite_ver" != 0.0 ]; then
		cp -r $TERMUX_PKG_SRCDIR/models/rife-v"${max_lite_ver%%.0}"-lite "$install_prefix/rife-v4-lite-latest"
	fi
	if [ "$max_ver" != 0.0 ]; then
		cp -r $TERMUX_PKG_SRCDIR/models/rife-v"${max_ver%%.0}" "$install_prefix/rife-v4-latest"
	fi
}

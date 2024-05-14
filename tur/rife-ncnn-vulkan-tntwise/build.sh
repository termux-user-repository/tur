TERMUX_PKG_HOMEPAGE=https://github.com/TNTwise/rife-ncnn-vulkan
TERMUX_PKG_DESCRIPTION="TNTwise's fork of rife-ncnn-vulkan: RIFE, Real-Time Intermediate Flow Estimation for Video Frame Interpolation implemented with ncnn library"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=20240326
TERMUX_PKG_SRCURL=git+https://github.com/TNTwise/rife-ncnn-vulkan
TERMUX_PKG_DEPENDS="libwebp, vulkan-loader"
TERMUX_PKG_ANTI_BUILD_DEPENDS="vulkan-loader"
TERMUX_PKG_BUILD_DEPENDS="vulkan-loader-generic"
TERMUX_PKG_GIT_BRANCH=20240326
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_TAG_TYPE="newest-tag"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="-DUSE_SYSTEM_WEBP=ON"
TERMUX_PKG_CONFLICTS="rife-ncnn-vulkan-nihui"

termux_step_pre_configure () {
	git submodule update --init --recursive "$TERMUX_PKG_SRCDIR"
	mv "$TERMUX_PKG_SRCDIR/src/"* "$TERMUX_PKG_SRCDIR/"
	LDFLAGS+=" -llog -landroid"
}

termux_step_make_install () {
	mkdir -p "$TERMUX_PREFIX/opt/rife-ncnn-vulkan"
	install -Dm700 rife-ncnn-vulkan "$TERMUX_PREFIX/opt/rife-ncnn-vulkan"
	ln -s "$TERMUX_PREFIX/opt/rife-ncnn-vulkan/rife-ncnn-vulkan" "$TERMUX_PREFIX/bin/rife-ncnn-vulkan"
	cp -r models/rife-v2.3 "$TERMUX_PREFIX/opt/rife-ncnn-vulkan/rife-v2.3" # default value of model arg
	cp -r models/rife-v4.6 "$TERMUX_PREFIX/opt/rife-ncnn-vulkan/rife-v4.6" # nihui's repo latest model
	max_ver=0.0
	max_lite_ver=0.0
	for rife_dir in models/rife-v*; do
		ver=$(basename "$rife_dir")
		ver=${ver##rife-v}
		[ "${#ver}" -eq 1 ] && ver="$ver.0"
		if [ "${ver: -5}" == "-lite" ] && ver="${ver::-5}"; then
			[ "${ver::1}" -ge "${max_lite_ver::1}" ] && [ "${ver:2}" -ge "${max_lite_ver:2}" ] && max_lite_ver="$ver"
		elif [ "${ver::1}" -ge "${max_ver::1}" ] && [ "${ver:2}" -ge "${max_ver:2}" ]; then
			max_ver="$ver"
		fi
	done
	[ "$max_lite_ver" != 0.0 ] && cp -r models/rife-v"${max_lite_ver%%.0}"-lite "$TERMUX_PREFIX/opt/rife-ncnn-vulkan/rife-lite-latest"
	[ "$max_ver" != 0.0 ] && cp -r models/rife-v"${max_ver%%.0}" "$TERMUX_PREFIX/opt/rife-ncnn-vulkan/rife-latest"
}

TERMUX_PKG_HOMEPAGE=https://swiftshader.googlesource.com/SwiftShader
TERMUX_PKG_DESCRIPTION="A high-performance CPU-based implementation of the Vulkan graphics API"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
_DATE=2022.12.08
TERMUX_PKG_VERSION=0.0.${_DATE//./}
TERMUX_PKG_SRCURL=https://github.com/google/swiftshader.git
TERMUX_PKG_DEPENDS="libandroid-shmem, vulkan-loader-android"
TERMUX_PKG_BUILD_DEPENDS="vulkan-headers"
TERMUX_PKG_GIT_BRANCH="master"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DSWIFTSHADER_WARNINGS_AS_ERRORS=FALSE
"

termux_step_get_source() {
	local TMP_CHECKOUT=$TERMUX_PKG_CACHEDIR/tmp-checkout
	local TMP_CHECKOUT_VERSION=$TERMUX_PKG_CACHEDIR/tmp-checkout-version

	if [ ! -f $TMP_CHECKOUT_VERSION ] || [ "$(cat $TMP_CHECKOUT_VERSION)" != "$TERMUX_PKG_VERSION" ]; then
		if [ "$TERMUX_PKG_GIT_BRANCH" == "" ]; then
			TERMUX_PKG_GIT_BRANCH=v$TERMUX_PKG_VERSION
		fi

		rm -rf $TMP_CHECKOUT
		git clone --depth 1 \
			--branch $TERMUX_PKG_GIT_BRANCH \
			$TERMUX_PKG_SRCURL \
			$TMP_CHECKOUT

		pushd $TMP_CHECKOUT
		git submodule update --init --recursive --depth=1
		popd

		echo "$TERMUX_PKG_VERSION" > $TMP_CHECKOUT_VERSION
	fi

	rm -rf $TERMUX_PKG_SRCDIR
	cp -Rf $TMP_CHECKOUT $TERMUX_PKG_SRCDIR
}

termux_step_configure() {
	termux_setup_cmake
	termux_setup_ninja
	termux_step_configure_cmake
}

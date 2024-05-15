TERMUX_PKG_HOMEPAGE=https://github.com/xinntao/Real-ESRGAN-ncnn-vulkan
TERMUX_PKG_DESCRIPTION="NCNN implementation of Real-ESRGAN for General Image Restoration."
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=0.2.0
TERMUX_PKG_SRCURL=git+https://github.com/xinntao/Real-ESRGAN-ncnn-vulkan
TERMUX_PKG_DEPENDS="libwebp"
TERMUX_PKG_BUILD_DEPENDS="vulkan-headers, vulkan-loader-android"
TERMUX_PKG_GIT_BRANCH="v$TERMUX_PKG_VERSION"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_TAG_TYPE="latest-release-tag"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="-DUSE_SYSTEM_WEBP=ON"

termux_step_get_source () {
	local TMP_CHECKOUT=$TERMUX_PKG_CACHEDIR/tmp-checkout
	local TMP_CHECKOUT_VERSION=$TERMUX_PKG_CACHEDIR/tmp-checkout-version

	if [ ! -f $TMP_CHECKOUT_VERSION ] || [ "$(cat $TMP_CHECKOUT_VERSION)" != "$TERMUX_PKG_VERSION" ]; then
		if [ "$TERMUX_PKG_GIT_BRANCH" == "" ]; then
			TERMUX_PKG_GIT_BRANCH=v${TERMUX_PKG_VERSION#*:}
		fi

		rm -rf $TMP_CHECKOUT
		git clone --depth 1 \
			--branch $TERMUX_PKG_GIT_BRANCH \
			${TERMUX_PKG_SRCURL:4} \
			$TMP_CHECKOUT

		pushd $TMP_CHECKOUT
		# >>>>> git submoudle patch here: url to https patch rather than ssh
		sed -i -e 's/git@github.com:/http:\/\/github.com\//g' "./.gitmodules"
		# <<<<<
		git submodule update --init --recursive --depth=1
		popd

		echo "$TERMUX_PKG_VERSION" > $TMP_CHECKOUT_VERSION
	fi

	rm -rf $TERMUX_PKG_SRCDIR
	cp -Rf $TMP_CHECKOUT $TERMUX_PKG_SRCDIR
}

termux_step_pre_configure() {
	# Install glslangValidator
	(unset sudo; sudo apt update; sudo apt install glslang-tools -yqq)
	

	LDFLAGS+=" -llog -landroid"

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
	install -Dm700 realesrgan-ncnn-vulkan "$install_prefix"
	ln -sfr $install_prefix/realesrgan-ncnn-vulkan $TERMUX_PREFIX/bin/

	# Install the system libvulkan.so
	local system_lib="/system/lib"
	[[ "${TERMUX_ARCH_BITS}" == "64" ]] && system_lib+="64"
	system_lib+="/libvulkan.so"
	ln -sf "$system_lib" "$install_prefix/"
	
	# Install models
	local URL="https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.5.0/realesrgan-ncnn-vulkan-20220424-ubuntu.zip"
	local TMP_FILE="$(mktemp)"
	curl -s -L -o "$TMP_FILE" "$URL"
	unzip -q -d "$install_prefix" "$TMP_FILE" "models/*"
	rm "$TMP_FILE"
}

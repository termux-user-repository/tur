TERMUX_PKG_HOMEPAGE=https://virgil3d.github.io/
TERMUX_PKG_DESCRIPTION="A virtual 3D GPU for use inside qemu virtual machines"
TERMUX_PKG_LICENSE="LGPL-2.1"
TERMUX_PKG_LICENSE_FILE="COPYING-LGPL2.1"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
_COMMIT=ab6e6f34077722d5ae33f6bd40b18ef9c0e99a15
TERMUX_PKG_VERSION="0.0.1-r139.${_COMMIT:0:7}"
TERMUX_PKG_SRCURL=git+https://github.com/vkmark/vkmark
TERMUX_PKG_GIT_BRANCH="master"
TERMUX_PKG_SHA256=2fde566a542fddc5c74a62c40dcb2d62e1151c7fbdc395adb1dc21857defa09d
TERMUX_PKG_DEPENDS="assimp, libc++, libxcb, glm, vulkan-loader-generic, xcb-util-wm"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="-Dxcb=true"

termux_step_post_get_source() {
	git fetch --unshallow
	git checkout $_COMMIT

	local version="$(printf "0.0.1-r%d.%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short HEAD)")"
	if [ "$version" != "$TERMUX_PKG_VERSION" ]; then
		echo -n "ERROR: The specified version \"$TERMUX_PKG_VERSION\""
		echo " is different from what is expected to be: \"$version\""
		return 1
	fi

	local s=$(find . -type f ! -path '*/.git/*' -print0 | xargs -0 sha256sum | LC_ALL=C sort | sha256sum)
	if [[ "${s}" != "${TERMUX_PKG_SHA256}  "* ]]; then
		termux_error_exit "Checksum mismatch for source files."
	fi
}

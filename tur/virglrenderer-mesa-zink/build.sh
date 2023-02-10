TERMUX_PKG_HOMEPAGE=https://virgil3d.github.io/
TERMUX_PKG_DESCRIPTION="A virtual 3D GPU for use inside qemu virtual machines"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=20220627
TERMUX_PKG_SRCURL=git+https://gitlab.freedesktop.org/virgl/virglrenderer
TERMUX_PKG_DEPENDS="libdrm, libepoxy, libglvnd, libx11, mesa-zink"
TERMUX_PKG_BUILD_DEPENDS="xorgproto"
TERMUX_PKG_CONFLICTS="virglrenderer"
TERMUX_PKG_REPLACES="virglrenderer"
TERMUX_PKG_PROVIDES="virglrenderer"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="-Dplatforms=egl,glx"

# Ref: https://github.com/ThieuMinh26/Proot-Setup/blob/25edeff7b45feffc4117276ef8245e94f7682766/Zink
termux_step_get_source() {
	local TMP_CHECKOUT=$TERMUX_PKG_CACHEDIR/tmp-checkout
	local TMP_CHECKOUT_VERSION=$TERMUX_PKG_CACHEDIR/tmp-checkout-version

	if [ ! -f $TMP_CHECKOUT_VERSION ] || [ "$(cat $TMP_CHECKOUT_VERSION)" != "$TERMUX_PKG_VERSION" ]; then
		rm -rf $TMP_CHECKOUT
		git clone --shallow-since 2022-06-27 ${TERMUX_PKG_SRCURL:4} $TMP_CHECKOUT

		pushd $TMP_CHECKOUT
		git checkout -f dd301caf7e05ec9c09634fb7872067542aad89b7~2
		popd

		echo "$TERMUX_PKG_VERSION" > $TMP_CHECKOUT_VERSION
	fi

	rm -rf $TERMUX_PKG_SRCDIR
	cp -Rf $TMP_CHECKOUT $TERMUX_PKG_SRCDIR
}

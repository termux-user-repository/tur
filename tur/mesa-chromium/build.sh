TERMUX_PKG_HOMEPAGE=https://www.mesa3d.org
TERMUX_PKG_DESCRIPTION="An open-source implementation of the OpenGL specification"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_LICENSE_FILE="docs/license.rst"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=22.3.0
TERMUX_PKG_SRCURL=https://archive.mesa3d.org/mesa-${TERMUX_PKG_VERSION}.tar.xz
TERMUX_PKG_SHA256=644bf936584548c2b88762111ad58b4aa3e4688874200e5a4eb74e53ce301746
TERMUX_PKG_DEPENDS="libandroid-shmem, libc++, libexpat, libx11, libxext, libxfixes, libxshmfence, libxxf86vm, ncurses, zlib, zstd"
TERMUX_PKG_BUILD_DEPENDS="libdrm, libllvm-static, libxrandr, llvm, llvm-tools, mlir, xorgproto"

TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--cmake-prefix-path $TERMUX_PREFIX
--prefix $TERMUX_PREFIX/opt/mesa-chromium
-Dcpp_rtti=false
-Dgbm=enabled
-Degl=enabled
-Degl-native-platform=x11
-Dgles1=enabled
-Dgles2=enabled
-Ddri3=enabled
-Dllvm=enabled
-Dshared-llvm=disabled
-Dglx=dri
-Dplatforms=x11
-Ddri-drivers=
-Dgallium-drivers=swrast
-Dvulkan-drivers=
-Dosmesa=true
"

termux_step_pre_configure() {
	termux_setup_cmake

	CPPFLAGS+=" -D__USE_GNU"
	LDFLAGS+=" -landroid-shmem"

	_WRAPPER_BIN=$TERMUX_PKG_BUILDDIR/_wrapper/bin
	mkdir -p $_WRAPPER_BIN
	if [ "$TERMUX_ON_DEVICE_BUILD" = "false" ]; then
		sed 's|@CMAKE@|'"$(command -v cmake)"'|g' \
			$TERMUX_PKG_BUILDER_DIR/cmake-wrapper.in \
			> $_WRAPPER_BIN/cmake
		chmod 0700 $_WRAPPER_BIN/cmake
	fi
	export PATH=$_WRAPPER_BIN:$PATH
}

termux_step_post_configure() {
	rm -f $_WRAPPER_BIN/cmake
}

termux_step_post_make_install() {
	patch -p1 -d $TERMUX_PREFIX/opt/mesa-chromium/include/ < $TERMUX_PKG_BUILDER_DIR/egl-not-android.diff
}

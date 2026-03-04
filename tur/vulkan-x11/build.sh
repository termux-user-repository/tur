TERMUX_PKG_SUGGESTED="libhardware-vulkan"
TERMUX_PKG_DEPENDS="vulkan-loader-generic"
TERMUX_PKG_DESCRIPTION="Vulkan x11 ICD provide display platforms xcb and xlib and GL zink swap chain"
TERMUX_PKG_VERSION=0
TERMUX_PKG_LICENSE="WTFPL"
TERMUX_PKG_SRCURL=(
# git+$HOME/wsi-twaik
git+https://github.com/john-peterson/vulkan-wsi-layer
)
TERMUX_PKG_GIT_BRANCH=xlib

termux_step_configure() { :; }
termux_step_make() { :; }
termux_step_make_install() {
cmake $TERMUX_PKG_SRCDIR -B . -D CMAKE_INSTALL_PREFIX=$TERMUX_PKG_MASSAGEDIR/$TERMUX_PREFIX   -D CMAKE_BUILD_TYPE=Debug -D ENABLE_INSTRUMENTATION=1 -D VULKAN_WSI_LAYER_EXPERIMENTAL=1  -D BUILD_WSI_IMAGE_COMPRESSION_CONTROL_SWAPCHAIN=1
mkdir $TERMUX_PKG_MASSAGEDIR/$TERMUX_PREFIX -p
make install -j4
# exit
}

termux_step_extract_into_massagedir() {
	# save five minutes of your day by skipping this 
	:;
}

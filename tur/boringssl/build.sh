
TERMUX_PKG_DESCRIPTION="boring ssl"
TERMUX_PKG_VERSION=0
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_SRCURL=git+https://github.com/google/boringssl
TERMUX_PKG_GIT_BRANCH=main
TERMUX_PKG_BUILD_DEPENDS="golang"
# TERMUX_PKG_DEPENDS="libnghttp2, libnghttp3, libssh2, openssl (>= 1:3.2.1-1), zlib"
TERMUX_PKG_DEPENDS="ca-certificates, zlib"
TERMUX_PKG_MAKE_PROCESSES=4
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="-DCMAKE_INSTALL_PREFIX=$TERMUX_PREFIX/opt/boringssl -DBUILD_SHARED_LIBS=ON"
# termux_step_configure() { :; }

# termux_step_make() { 

# }


termux_step_post_make_install() {
	mv $TERMUX_PREFIX
}

# termux_step_extract_into_massagedir() { :; }

# termux_step_post_massage() { :; }



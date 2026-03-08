
TERMUX_PKG_DESCRIPTION="curl impersonation for curl_cffi"
TERMUX_PKG_VERSION=8.1.1
TERMUX_PKG_LICENSE="MIT"
# TERMUX_PKG_SRCURL=git+https://github.com/lwthiker/curl-impersonate
# TERMUX_PKG_GIT_BRANCH=main
TERMUX_PKG_SRCURL=git+https://github.com/john-peterson/curl
TERMUX_PKG_GIT_BRANCH=imp
TERMUX_PKG_BUILD_DEPENDS="golang"
TERMUX_PKG_DEPENDS="boringssl, brotli, libnghttp2, libnghttp3, libssh2, zlib"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS=" -DUSE_NGHTTP2=ON -DCURL_BROTLI=ON -DOPENSSL_ROOT_DIR=$TERMUX_PREFIX/opt/boringssl -DBUILD_SHARED_LIBS=ON  "
# -DCMAKE_CXX_FLAGS:=-fno-exceptions
TERMUX_PKG_MAKE_PROCESSES=4

termux_step_pre_configure() {
# export CXXFLAGS=-fno-exceptions
export CFLAGS=-fno-exceptions
}

termux_step_post_configure() {
	ack fno-exc build.ninja || exit
	# exit
:; 
}

# termux_step_make() { 
# make chrome-build -C ../build
# }

# termux_step_make_install() {
	# mkdir -p $TERMUX_PKG_MASSAGEDIR/$TERMUX_PREFIX/lib
	# cp $TERMUX_PKG_BUILDDIR/* $TERMUX_PKG_MASSAGEDIR/$TERMUX_PREFIX/lib/
	# :;
# }

# termux_step_extract_into_massagedir() { :; }

# termux_step_post_massage() { :; }



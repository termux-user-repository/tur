TERMUX_PKG_HOMEPAGE=https://oils.pub/
TERMUX_PKG_DESCRIPTION="Oils for Unix: OSH and YSH shells"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="0.38.0"
TERMUX_PKG_SRCURL="https://oils.pub/download/oils-for-unix-$TERMUX_PKG_VERSION.tar.gz"
TERMUX_PKG_SHA256=a33453722819b55ee552bfd7f3c2bab8f1940def55d5c8b46af16ce95bdf8803
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_DEPENDS="libandroid-glob, readline, libc++"
TERMUX_PKG_BUILD_DEPENDS="aosp-libs"

termux_step_pre_configure() {
	if [[ "$TERMUX_ON_DEVICE_BUILD" == "false" ]]; then
		termux_setup_proot
		local patch="$TERMUX_PKG_BUILDER_DIR/termux-proot-run-configure.diff"
		echo "Applying patch: $(basename $patch)"
		patch -p1 --silent < "$patch"
	fi

	export OILS_CXX_VERBOSE=1
	export CXXFLAGS="$CXXFLAGS $CPPFLAGS"
	export LDFLAGS+=" -landroid-glob"
}

termux_step_configure() {
	./configure \
		--prefix="$TERMUX_PREFIX" \
		--with-readline \
		--cxx-for-configure="$CXX"
}

termux_step_make() {
	_build/oils.sh --cxx "$CXX"
}

termux_step_make_install() {
	./install "_bin/$CXX-opt-sh/oils-for-unix"
}

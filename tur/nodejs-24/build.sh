TERMUX_PKG_HOMEPAGE=https://nodejs.org/
TERMUX_PKG_DESCRIPTION="Open Source, cross-platform JavaScript runtime environment"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=24.17.0
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=https://nodejs.org/dist/v${TERMUX_PKG_VERSION}/node-v${TERMUX_PKG_VERSION}.tar.xz
TERMUX_PKG_SHA256=a7ab562ed2369a29c68b72fa00e3103bcdfe37063dff799c6acc8e404e275fcd
# Note that we do not use a shared libuv to avoid an issue with the Android
# linker, which does not use symbols of linked shared libraries when resolving
# symbols on dlopen(). See https://github.com/termux/termux-packages/issues/462.
TERMUX_PKG_DEPENDS="libc++, openssl, c-ares, zlib"
TERMUX_PKG_SUGGESTS="clang, make, pkg-config, python"
_INSTALL_PREFIX=opt/nodejs-24
TERMUX_PKG_RM_AFTER_INSTALL="
$_INSTALL_PREFIX/lib/node_modules/npm/html
$_INSTALL_PREFIX/lib/node_modules/npm/make.bat
$_INSTALL_PREFIX/share/systemtap
$_INSTALL_PREFIX/lib/dtrace
"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_HOSTBUILD=true

termux_step_post_get_source() {
	# Prevent caching of host build:
	rm -Rf $TERMUX_PKG_HOSTBUILD_DIR
}

termux_step_host_build() {
	######
	# Download LLVM toolchain used by the upstream v8 project.
	# Upstream v8 uses LLVM tooling from the main branch of the LLVM project as
	# the main branch often contains bug fixes which are not released quickly to
	# stable releases. Also Ubuntu's LLVM toolchain is too old in comparison to
	# what Google uses.
	######

	# The LLVM_COMMIT, as well as the tarball of the LLVM build by Google in use
	# can be found in deps/v8/DEPS file,
	#
	# For instance, if the deps/v8/DEPS file contains:
	#
	#   'third_party/llvm-build/Release+Asserts': {
	#  'dep_type': 'gcs',
	#  'bucket': 'chromium-browser-clang',
	#  'objects': [
	#    {
	#      'object_name': 'Linux_x64/clang-llvmorg-21-init-5118-g52cd27e6-5.tar.xz',
	#      'sha256sum': '790fcc5b04e96882e8227ba7994161ab945c0e096057fc165a0f71e32a7cb061',
	#      'size_bytes': 54517328,
	#      'generation': 1742541959624765,
	#      'condition': 'host_os == "linux"',
	#    },
	#
	# then the LLVM_COMMIT is 52cd27e6. The g before the hash is not part of the
	# hash, weird that they decided to include a 'g' for no reason, but 'g' isn't
	# a part of the hexadecimal characters so anyways.. Also v8 project only
	# stores the short-hash in the DEPS file, but we are using full hash here for
	# clarity. The full hash can be obtained by having a full checkout of the
	# llvm-project locally and then running `git log --format=%H -n 1` in the
	# llvm-project directory.
	#
	# Also the sha256sum is the hash of the tarball, which we can directly use
	local LLVM_TAR="clang-llvmorg-21-init-5118-g52cd27e6-5.tar.xz"
	local LLVM_TAR_HASH=790fcc5b04e96882e8227ba7994161ab945c0e096057fc165a0f71e32a7cb061
	cd $TERMUX_PKG_HOSTBUILD_DIR
	mkdir llvm-project-build
	termux_download \
			"https://commondatastorage.googleapis.com/chromium-browser-clang/Linux_x64/${LLVM_TAR}" \
			"${TERMUX_PKG_CACHEDIR}/${LLVM_TAR}" \
			"${LLVM_TAR_HASH}"
	tar --extract -f "${TERMUX_PKG_CACHEDIR}/${LLVM_TAR}" --directory=llvm-project-build
}

termux_step_pre_configure() {
	termux_setup_ninja
}

termux_step_configure() {
	local DEST_CPU
	if [ $TERMUX_ARCH = "arm" ]; then
		DEST_CPU="arm"
	elif [ $TERMUX_ARCH = "i686" ]; then
		DEST_CPU="ia32"
	elif [ $TERMUX_ARCH = "aarch64" ]; then
		DEST_CPU="arm64"
	elif [ $TERMUX_ARCH = "x86_64" ]; then
		DEST_CPU="x64"
	else
		termux_error_exit "Unsupported arch '$TERMUX_ARCH'"
	fi

	export GYP_DEFINES="host_os=linux"
	if [ "$TERMUX_ARCH_BITS" = "64" ]; then
		export CC_host="$TERMUX_PKG_HOSTBUILD_DIR/llvm-project-build/bin/clang"
		export CXX_host="$TERMUX_PKG_HOSTBUILD_DIR/llvm-project-build/bin/clang++"
		export LINK_host="$TERMUX_PKG_HOSTBUILD_DIR/llvm-project-build/bin/clang++"
	else
		export CC_host="$TERMUX_PKG_HOSTBUILD_DIR/llvm-project-build/bin/clang -m32"
		export CXX_host="$TERMUX_PKG_HOSTBUILD_DIR/llvm-project-build/bin/clang++ -m32"
		export LINK_host="$TERMUX_PKG_HOSTBUILD_DIR/llvm-project-build/bin/clang++ -m32"
	fi

	mkdir -p $TERMUX_PREFIX/$_INSTALL_PREFIX
	LDFLAGS="-Wl,-rpath=$TERMUX_PREFIX/$_INSTALL_PREFIX/lib $LDFLAGS"

	# Although without any configuration at all GYP builds both out/Release/ and out/Debug/
	# with build.ninja, it is incorrect to use the other directory as configure.py passes
	# a build_type variable to GYP which it uses to detect release/debug builds which is
	# used in some places to do some debug build specific stuff.
	# An example of such errors is the builds failing due to undefined symbols of some
	# generated source files that happen only in debug builds
	local _DEBUG=()
	if [ "${TERMUX_DEBUG_BUILD}" = "true" ]; then
		_DEBUG+=("--debug")
	fi

	# See note above TERMUX_PKG_DEPENDS why we do not use a shared libuv
	# When building with ninja, build.ninja is geenrated for both Debug and Release builds.
	./configure \
		--prefix=$TERMUX_PREFIX/$_INSTALL_PREFIX \
		--dest-cpu=$DEST_CPU \
		--dest-os=android \
		--shared-cares \
		--shared-openssl \
		--shared-zlib \
		--with-intl=full-icu \
		--cross-compiling \
		--ninja \
		"${_DEBUG[@]}"

	sed -i \
		-e "s|\-I$TERMUX_PREFIX/include| |g" \
		-e "s|\-L$TERMUX_PREFIX/lib| |g" \
		$(find $TERMUX_PKG_SRCDIR/out/{Release,Debug}/obj.host -name '*.ninja')
}

termux_step_make() {
	if [ "${TERMUX_DEBUG_BUILD}" = "true" ]; then
		ninja -C out/Debug -j "${TERMUX_PKG_MAKE_PROCESSES}"
	else
		ninja -C out/Release -j "${TERMUX_PKG_MAKE_PROCESSES}"
	fi
}

termux_step_make_install() {
	local _BUILD_DIR=out/
	if [ "${TERMUX_DEBUG_BUILD}" = "true" ]; then
		_BUILD_DIR+="/Debug/"
	else
		_BUILD_DIR+="/Release/"
	fi
	python tools/install.py install --dest-dir="" --prefix "$TERMUX_PREFIX/$_INSTALL_PREFIX" --build-dir "$_BUILD_DIR"
}

TERMUX_PKG_HOMEPAGE=https://nodejs.org/
TERMUX_PKG_DESCRIPTION="Open Source, cross-platform JavaScript runtime environment (Version 22)"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=22.15.1
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=https://nodejs.org/dist/v${TERMUX_PKG_VERSION}/node-v${TERMUX_PKG_VERSION}.tar.xz
TERMUX_PKG_SHA256=c19f0177d21c621746625e5f37590bd0d79a72043b77b53784cba5f145e7263e
# Note that we do not use a shared libuv to avoid an issue with the Android
# linker, which does not use symbols of linked shared libraries when resolving
# symbols on dlopen(). See https://github.com/termux/termux-packages/issues/462.
TERMUX_PKG_DEPENDS="libc++, openssl, c-ares, libicu, zlib"
TERMUX_PKG_SUGGESTS="clang, make, pkg-config, python"
_INSTALL_PREFIX=opt/nodejs-22
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

termux_step_pre_configure() {
	termux_setup_ninja
}

termux_step_host_build() {
	######
	# Download LLVM toolchain used by the upstream v8 project.
	# Upstream v8 uses LLVM tooling from the main branch of the LLVM project as
	# the main branch often contains bug fixes which are not released quickly to
	# stable releases. Also Ubuntu's LLVM toolchain is too old in comparison to
	# what Google uses.
	######

	# Instructions to find the LLVM_COMMIT and LLVM_TAR_HASH used by the v8
	# version in nodejs:
	#
	# Look into the deps/v8/DEPS file, and look for the 'tools/clang' entry.
	#  'tools/clang':
	#    Var('chromium_url') + '/chromium/src/tools/clang.git' + '@' + '6c4f037a983abf14a4c8bf00e44db73cdf330a97',
	#
	# You can now choose to either choose to do a full checkout of the v8 commit
	# and do `gclient sync` to get the full tree, or just peek at
	# https://chromium.googlesource.com/chromium/src/tools/clang.git/+/6c4f037a983abf14a4c8bf00e44db73cdf330a97/scripts/update.py
	# Look at the CLANG_REVISION and CLANG_SUB_REVISION variable,
	# LLVM_TAR="${CLANG_REVISION}-${CLANG_SUB_REVISION}.tar.xz"
	#
	# From scripts/update.py
	# 39 | CLANG_REVISION = 'llvmorg-21-init-9266-g09006611'
	# 40 | CLANG_SUB_REVISION = 1
	#
	# then the LLVM_COMMIT is 09006611.
	# LLVM_TAR_HASH is not available in the DEPS file, so you need to do a
	# download yourself to find it
	#
	# NOTE: If you are not able to find the LLVM_COMMIT according to the above instructions,
	#       this is because of https://chromium.googlesource.com/v8/v8.git/+/e5ffb0f66d122129a04cf1f4ffcf6a6e3b956ee0
	#       nodejs-lts comes with an older version of v8 which does not have this patch.
	#       Updated instructions can be found in the build.sh file for nodejs package
	local LLVM_TAR="clang-llvmorg-21-init-9266-g09006611-1.tar.xz"
	local LLVM_TAR_HASH=2cccd3a5b04461f17a2e78d2f8bd18b448443a9dd4d6dfac50e8e84b4d5176f1
	cd $TERMUX_PKG_HOSTBUILD_DIR
	mkdir llvm-project-build
	termux_download \
			"https://commondatastorage.googleapis.com/chromium-browser-clang/Linux_x64/${LLVM_TAR}" \
			"${TERMUX_PKG_CACHEDIR}/${LLVM_TAR}" \
			"${LLVM_TAR_HASH}"
	tar --extract -f "${TERMUX_PKG_CACHEDIR}/${LLVM_TAR}" --directory=llvm-project-build
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
		--ninja

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
	if [ "${TERMUX_DEBUG_BUILD}" = "true" ]; then
		python tools/install.py install --dest-dir="" --prefix "$TERMUX_PREFIX/$_INSTALL_PREFIX" --build-dir out/Debug/
	else
		python tools/install.py install --dest-dir="" --prefix "$TERMUX_PREFIX/$_INSTALL_PREFIX" --build-dir out/Release/
	fi
}

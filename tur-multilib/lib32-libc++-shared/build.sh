TERMUX_PKG_HOMEPAGE=https://libcxx.llvm.org/
TERMUX_PKG_DESCRIPTION="C++ Standard Library"
TERMUX_PKG_LICENSE="NCSA"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
# Version should be equal to TERMUX_NDK_{VERSION_NUM,REVISION} in
# scripts/properties.sh
TERMUX_PKG_VERSION=25c
TERMUX_PKG_SRCURL=https://dl.google.com/android/repository/android-ndk-r${TERMUX_PKG_VERSION}-linux.zip
TERMUX_PKG_SHA256=769ee342ea75f80619d985c2da990c48b3d8eaf45f48783a2d48870d04b46108
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_BREAKS="ndk-multilib"
TERMUX_PKG_CONFLICTS="ndk-multilib"

source $TERMUX_SCRIPTDIR/common-files/setup_multilib_toolchain.sh

termux_step_post_make_install() {
	mkdir -p "$TERMUX_PREFIX"/lib/$TUR_MULTILIB_ARCH_TRIPLE
	install -m700 -t "$TERMUX_PREFIX"/lib/$TUR_MULTILIB_ARCH_TRIPLE \
		toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/"${TUR_MULTILIB_ARCH_TRIPLE}"/libc++_shared.so
}

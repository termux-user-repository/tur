TERMUX_PKG_HOMEPAGE=http://www.openblas.net/
TERMUX_PKG_DESCRIPTION="An optimized BLAS library"
TERMUX_PKG_LICENSE="BSD 3-Clause"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=0.3.20
TERMUX_PKG_SRCURL=https://github.com/xianyi/OpenBLAS.git
TERMUX_PKG_FORCE_CMAKE=true

if $TERMUX_ON_DEVICE_BUILD; then
	termux_error_exit "Package '$TERMUX_PKG_NAME' is not available for on-device builds."
fi

# XXX: This step will setup an old NDK toolchain (r13b) containing gcc and
# XXX: gfortran. If NDK toolchain with llvm contains fortran compiler, this
# XXX: step may be unnecessary.
_setup_fortran_toolchain_r13b() {
	mkdir -p $TERMUX_COMMON_CACHEDIR/android-gfortran/r13b
	local _NDK_ARCHIVE_FILE=$TERMUX_COMMON_CACHEDIR/android-gfortran/android-ndk-r13b-linux-x86_64.zip
	local _NDK_URL=https://dl.google.com/android/repository/android-ndk-r13b-linux-x86_64.zip
	local _NDK_SHA256=3524d7f8fca6dc0d8e7073a7ab7f76888780a22841a6641927123146c3ffd29c
	local _NDK_GF_ARCH
	local _NDK_GF_SHA256
	if [ "$TERMUX_ARCH" == "aarch64" ]; then
		_NDK_GF_ARCH="arm64"
		_NDK_GF_SHA256=8810eb94682bff79d56800713a1845761e6f6636ab6d13ee1968d5b36834d60b
		_NDK_GF_TOOLCHAIN_NAME="aarch64-linux-android-4.9"
	elif [ "$TERMUX_ARCH" == "arm" ]; then
		_NDK_GF_ARCH="arm"
		_NDK_GF_SHA256=82d9f8e6c6c08d6e630dd43780526b371076fab489b5b7244ceba7702630121a
		_NDK_GF_TOOLCHAIN_NAME="arm-linux-androideabi-4.9"
	elif [ "$TERMUX_ARCH" == "x86_64" ]; then
		_NDK_GF_ARCH="x86_64"
		_NDK_GF_SHA256=7d897a05c28e16f0c357c1be5ad1ddee173882a5056506d5bfc6c84e94387976
		_NDK_GF_TOOLCHAIN_NAME="x86_64-4.9"
	elif [ "$TERMUX_ARCH" == "i686" ]; then
		_NDK_GF_ARCH="x86"
		_NDK_GF_SHA256=50e27874d965f0ae18973e99e2f5de35eef74d19bc478d3f6649fa3ed411e84a
		_NDK_GF_TOOLCHAIN_NAME="x86-4.9"
	fi
	local _NDK_GF_FILE=$TERMUX_COMMON_CACHEDIR/android-gfortran/r13b/gcc-$_NDK_GF_ARCH-linux-x86_64.tar.bz2
	local _NDK_GF_URL=https://github.com/buffer51/android-gfortran/releases/download/r13b/gcc-$_NDK_GF_ARCH-linux-x86_64.tar.bz2
	local _NDK_TOOLCHAIN_TARGET=$TERMUX_PKG_TMPDIR/android-ndk-r13b/toolchains/$_NDK_GF_TOOLCHAIN_NAME/prebuilt/linux-x86_64
	termux_download $_NDK_URL $_NDK_ARCHIVE_FILE $_NDK_SHA256
	unzip -d $TERMUX_PKG_TMPDIR/ $_NDK_ARCHIVE_FILE > /dev/null 2>&1
	termux_download $_NDK_GF_URL $_NDK_GF_FILE $_NDK_GF_SHA256
	tar -jxf $_NDK_GF_FILE -C $TERMUX_PKG_TMPDIR/
	rm -rf $_NDK_TOOLCHAIN_TARGET
	mv $TERMUX_PKG_TMPDIR/$_NDK_GF_TOOLCHAIN_NAME $_NDK_TOOLCHAIN_TARGET
	GFORTRAN_TOOLCHAIN=$TERMUX_PKG_TMPDIR/ndk-$TERMUX_ARCH-with-gfortran
	python $TERMUX_PKG_TMPDIR/android-ndk-r13b/build/tools/make_standalone_toolchain.py \
					--arch $_NDK_GF_ARCH --api $TERMUX_PKG_API_LEVEL --install-dir $GFORTRAN_TOOLCHAIN
	TERMUX_STANDALONE_TOOLCHAIN="$GFORTRAN_TOOLCHAIN"
}

termux_step_pre_configure() {
	# XXX: libncurses5 is used by `clang38`.
	# XXX: So should TUR use a custom builder image?
	env -i PATH="$PATH" sudo apt update
	env -i PATH="$PATH" sudo apt install -y libncurses5

	_setup_fortran_toolchain_r13b

	CXXFLAGS=""
	CFLAGS=""
	LDFLAGS=""

	local CROSS_PREFIX=$TERMUX_ARCH-linux-android

	if [ "$TERMUX_ARCH" == "arm" ]; then
		CROSS_PREFIX=arm-linux-androideabi
	elif [ "$TERMUX_ARCH" == "x86_64" ] || [ "$TERMUX_ARCH" == "i686" ]; then
		# XXX: CORE2 seems too old. So which target should be set for openblas?
		TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" -DTARGET=CORE2"
	fi

	# Backup these environment variables, since they are used by the building system.
	_OLD_AR="$AR"
	_OLD_STRIP="$STRIP"
	_OLD_PATH="$PATH"

	export AR=$CROSS_PREFIX-ar
	export AS=$CROSS_PREFIX-as
	export LD=$CROSS_PREFIX-ld
	export NM=$CROSS_PREFIX-nm
	export CC=$CROSS_PREFIX-gcc
	export FC=$CROSS_PREFIX-gfortran
	export CXX=$CROSS_PREFIX-g++
	export CPP=$CROSS_PREFIX-cpp
	export CXXCPP=$CROSS_PREFIX-cpp
	export STRIP=$CROSS_PREFIX-strip
	export RANLIB=$CROSS_PREFIX-ranlib
	export STRINGS=$CROSS_PREFIX-strings
	export PATH="$TERMUX_STANDALONE_TOOLCHAIN/bin:$PATH"

	TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" -DBUILD_SHARED_LIBS=ON -DBUILD_STATIC_LIBS=ON"
}

termux_step_post_make_install() {
	# Recover these environment variables.
	AR="$_OLD_AR"
	STRIP="$_OLD_STRIP"
	PATH="$_OLD_PATH"
}

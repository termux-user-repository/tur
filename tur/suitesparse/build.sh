TERMUX_PKG_HOMEPAGE=https://github.com/DrTimothyAldenDavis/SuiteSparse
TERMUX_PKG_DESCRIPTION="A Suite of Sparse matrix packages."
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="1:7.7.0"
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=https://github.com/DrTimothyAldenDavis/SuiteSparse/archive/refs/tags/v${TERMUX_PKG_VERSION#*:}.tar.gz
TERMUX_PKG_SHA256=529b067f5d80981f45ddf6766627b8fc5af619822f068f342aab776e683df4f3
TERMUX_PKG_DEPENDS="libandroid-complex-math, blas-openblas, libopenblas, libgmp, libmpfr"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_FORCE_CMAKE=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DCMAKE_SYSTEM_NAME=Linux
-DBLA_VENDOR=Generic
-DALLOW_64BIT_BLAS=OFF
-DGRAPHBLAS_CROSS_TOOLCHAIN_FLAGS_NATIVE=\"-DCMAKE_TOOLCHAIN_FILE=$TERMUX_PKG_BUILDER_DIR/graphblas-host-toolchain.cmake\"
"

source $TERMUX_SCRIPTDIR/common-files/setup_toolchain_gcc.sh

termux_step_pre_configure() {
	_setup_toolchain_ndk_gcc_11
}

termux_step_configure() {
	termux_setup_cmake
}

termux_step_make() {
	MAKE_PROGRAM_PATH=$(command -v make)
	BUILD_TYPE=Release
	test "$TERMUX_DEBUG_BUILD" == "true" && BUILD_TYPE=Debug
	CMAKE_PROC=$TERMUX_ARCH
	test $CMAKE_PROC == "arm" && CMAKE_PROC='armv7-a'

	local CMAKE_OPTIONS=
	if [ "$TERMUX_ON_DEVICE_BUILD" = "false" ]; then
		CXXFLAGS+=" -D__ANDROID_API__=$TERMUX_PKG_API_LEVEL"
		CFLAGS+=" -D__ANDROID_API__=$TERMUX_PKG_API_LEVEL"
		LDFLAGS+=" -D__ANDROID_API__=$TERMUX_PKG_API_LEVEL"

		CMAKE_OPTIONS+=" -DCMAKE_CROSSCOMPILING=True"
		CMAKE_OPTIONS+=" -DCMAKE_LINKER=\"$GCC_STANDALONE_TOOLCHAIN/bin/$LD $LDFLAGS\""
		CMAKE_OPTIONS+=" -DCMAKE_SYSTEM_NAME=Android"
		CMAKE_OPTIONS+=" -DCMAKE_SYSTEM_VERSION=$TERMUX_PKG_API_LEVEL"
		CMAKE_OPTIONS+=" -DCMAKE_SYSTEM_PROCESSOR=$CMAKE_PROC"
		CMAKE_OPTIONS+=" -DCMAKE_ANDROID_STANDALONE_TOOLCHAIN=$GCC_STANDALONE_TOOLCHAIN"
	else
		CMAKE_OPTIONS+=" -DCMAKE_LINKER=\"$(command -v $LD) $LDFLAGS\""
	fi

	CMAKE_OPTIONS+=" -DCMAKE_AR=\"$(command -v $AR)\""
	CMAKE_OPTIONS+=" -DCMAKE_UNAME=\"$(command -v uname)\""
	CMAKE_OPTIONS+=" -DCMAKE_RANLIB=\"$(command -v $RANLIB)\""
	CMAKE_OPTIONS+=" -DCMAKE_STRIP=\"$(command -v $STRIP)\""
	CMAKE_OPTIONS+=" -DCMAKE_BUILD_TYPE=$BUILD_TYPE"
	CMAKE_OPTIONS+=" -DCMAKE_C_FLAGS=\"$CFLAGS $CPPFLAGS\""
	CMAKE_OPTIONS+=" -DCMAKE_CXX_FLAGS=\"$CXXFLAGS $CPPFLAGS\""
	CMAKE_OPTIONS+=" -DCMAKE_FIND_ROOT_PATH=$TERMUX_PREFIX"
	CMAKE_OPTIONS+=" -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER"
	CMAKE_OPTIONS+=" -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=NEVER"
	CMAKE_OPTIONS+=" -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=NEVER"
	CMAKE_OPTIONS+=" -DCMAKE_INSTALL_PREFIX=$TERMUX_PREFIX"
	CMAKE_OPTIONS+=" -DCMAKE_INSTALL_LIBDIR=$TERMUX_PREFIX/lib"
	CMAKE_OPTIONS+=" -DCMAKE_MAKE_PROGRAM=$MAKE_PROGRAM_PATH"
	CMAKE_OPTIONS+=" -DCMAKE_SKIP_INSTALL_RPATH=ON"
	CMAKE_OPTIONS+=" -DCMAKE_USE_SYSTEM_LIBRARIES=True"
	CMAKE_OPTIONS+=" -DDOXYGEN_EXECUTABLE="
	CMAKE_OPTIONS+=" -DBUILD_TESTING=OFF"
	CMAKE_OPTIONS+=" $(echo $TERMUX_PKG_EXTRA_CONFIGURE_ARGS)"

	make -j $TERMUX_MAKE_PROCESSES \
		CMAKE_OPTIONS="$CMAKE_OPTIONS" JOBS=$TERMUX_MAKE_PROCESSES
}

termux_step_make_install() {
	make install INSTALL=$TERMUX_PREFIX
}

termux_step_post_massage() {
	# Do not forget to bump revision of reverse dependencies and rebuild them
	# after SOVERSION is changed.
	# local _SOVERSION_GUARD_FILES=$(find lib/ | grep -E '\.so\.[0-9]+$' | sort)
	local _SOVERSION_GUARD_FILES="
lib/libamd.so.3
lib/libbtf.so.2
lib/libcamd.so.3
lib/libccolamd.so.3
lib/libcholmod.so.5
lib/libcolamd.so.3
lib/libcxsparse.so.4
lib/libgraphblas.so.9
lib/libklu.so.2
lib/libklu_cholmod.so.2
lib/liblagraph.so.1
lib/liblagraphx.so.1
lib/libldl.so.3
lib/libparu.so.0
lib/librbio.so.4
lib/libspex.so.3
lib/libspexpython.so.3
lib/libspqr.so.4
lib/libsuitesparse_mongoose.so.3
lib/libsuitesparseconfig.so.7
lib/libumfpack.so.6
"
	local f
	for f in ${_SOVERSION_GUARD_FILES}; do
		if [ ! -e "${f}" ]; then
			termux_error_exit "SOVERSION guard check failed."
		fi
	done
}

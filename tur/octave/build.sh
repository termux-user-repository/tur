TERMUX_PKG_HOMEPAGE=https://octave.org
TERMUX_PKG_DESCRIPTION="GNU Octave is a high-level language, primarily intended for numerical computations. (only CLI)"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=7.3.0
TERMUX_PKG_SRCURL=https://ftpmirror.gnu.org/octave/octave-${TERMUX_PKG_VERSION}.tar.xz
TERMUX_PKG_SHA256=a508ee6aebccfa68967c9e7e0a08793c4ca8e4ddace723aabdb8f71ad34d57f1
TERMUX_PKG_DEPENDS="zlib, bzip2, openssl, libiconv, libandroid-glob, pcre, readline, libcurl, libhdf5, qhull, rapidjson, fftw, glpk, libopenblas, arpack-ng, qrupdate-ng, suitesparse, sundials, fontconfig, freetype, graphicsmagick, libsndfile, portaudio"
TERMUX_PKG_BUILD_DEPENDS="gnuplot, less"
TERMUX_PKG_RECOMMENDS="gnuplot, less"
TERMUX_PKG_CONFLICTS="octave-x"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--without-x
--enable-link-all-dependencies
--with-blas=openblas
--with-openssl=yes
--with-libiconv-prefix=$TERMUX_PREFIX
ac_cv_func_getpwuid=no
ac_cv_func_getpwent=no
ac_cv_func_getpwnam=no
ac_cv_func_getpwnam_r=no
ac_cv_func_setpwuid=no
ac_cv_func_setpwent=no
ac_cv_func_endpwent=no
ac_cv_func_getgrent=no
ac_cv_func_setgrent=no
ac_cv_func_getgrgid=no
ac_cv_func_getgrnam=no
ac_cv_func_getegid=no
ac_cv_func_geteuid=no
ac_cv_func_getlogin_r=no
ac_cv_func_getrandom=no
ac_cv_func_nl_langinfo=no
"

source $TERMUX_SCRIPTDIR/common-files/setup_toolchain_gcc.sh

termux_step_pre_configure() {
	_setup_toolchain_ndk_with_gfortran_11
	autoreconf -fiv
	LDFLAGS="${LDFLAGS/-static-openmp/} -Wl,-rpath,$TERMUX_PREFIX/lib/octave/$TERMUX_PKG_VERSION"
	NDK_ARCH=$TERMUX_ARCH
        test $NDK_ARCH == 'i686' && NDK_ARCH='i386'
	if [ $NDK_ARCH == 'arm' ]; then
		NDK_TRIPLET="${NDK_ARCH}-linux-androideabi"
		GCC_TRIPLET="${NDK_ARCH}-linux-androideabi"
	elif [ $NDK_ARCH == 'i386' ]; then
		NDK_TRIPLET="${NDK_ARCH}-linux-android"
		GCC_TRIPLET="i686-linux-android"
	else
		NDK_TRIPLET="${NDK_ARCH}-linux-android"
		GCC_TRIPLET="${NDK_ARCH}-linux-android"
	fi
	
        # clang 13+ requires libunwind on Android.
        cp "$TERMUX_STANDALONE_TOOLCHAIN/lib64/clang/14.0.6/lib/linux/$NDK_ARCH/libunwind.a" \
	   "$TERMUX_PKG_BUILDDIR" || exit 1
	cp "$GCC_STANDALONE_TOOLCHAIN/lib/gcc/$GCC_TRIPLET/"11.*/libgcc.a \
	   "$TERMUX_PKG_BUILDDIR" || exit 1
	cp "$GCC_STANDALONE_TOOLCHAIN/$GCC_TRIPLET/"lib*/libgfortran.a \
	   "$TERMUX_PKG_BUILDDIR" || exit 1
	LIBQUADMATH=
	if [ $TERMUX_ARCH == 'i686' -o $TERMUX_ARCH == 'x86_64' ]; then
		cp "$GCC_STANDALONE_TOOLCHAIN/$GCC_TRIPLET/"lib*/libquadmath.a \
		   "$TERMUX_PKG_BUILDDIR" || exit 1
		LIBQUADMATH="$TERMUX_PKG_BUILDDIR/libquadmath.a"
	fi
	export LIBS="-landroid-glob -L$TERMUX_PKG_BUILDDIR $TERMUX_PKG_BUILDDIR/libunwind.a $TERMUX_PKG_BUILDDIR/libgfortran.a $LIBQUADMATH $TERMUX_PKG_BUILDDIR/libgcc.a"
}

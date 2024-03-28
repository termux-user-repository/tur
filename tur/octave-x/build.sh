TERMUX_PKG_HOMEPAGE=https://octave.org
TERMUX_PKG_DESCRIPTION="GNU Octave is a high-level language, primarily intended for numerical computations. (with X11 support)"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=1:8.4.0
TERMUX_PKG_REVISION=4
TERMUX_PKG_SRCURL=https://ftpmirror.gnu.org/octave/octave-${TERMUX_PKG_VERSION#*:}.tar.xz
TERMUX_PKG_SHA256=6f9ad73a3ee4291b6341d6c0f5e5c85d6e0310376e4991b959a6d340b3ffa8a8
TERMUX_PKG_DEPENDS="arpack-ng, bzip2, fftw, fltk, fontconfig, freetype, glpk, glu, graphicsmagick, libcurl, libhdf5, libiconv, libopenblas, libsndfile, opengl, openssl, pcre, portaudio, qhull, qrupdate-ng, rapidjson, readline, suitesparse, sundials, zlib"
TERMUX_PKG_BUILD_DEPENDS="gnuplot, less"

# Qt-GUI cannot be enabled, because `qcollectiongenerator` and
# `qhelpgenerator` is not exist at host.
#TERMUX_PKG_DEPENDS="zlib, bzip2, openssl, libiconv, pcre, readline, libcurl, libhdf5, qhull, rapidjson, fftw, glpk, libopenblas, arpack-ng, qrupdate-ng, suitesparse, sundials, fontconfig, freetype, graphicsmagick, libsndfile, portaudio, fltk, mesa, glu, qt5-qtbase, qt5-qttools, qscintilla""
#TERMUX_PKG_BUILD_DEPENDS="gnuplot, less, qt5-qtbase-cross-tools, qt5-qttools-cross-tools"

TERMUX_PKG_RECOMMENDS="gnuplot, less"
TERMUX_PKG_CONFLICTS="octave"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--with-x
--enable-link-all-dependencies
--disable-openmp
--with-blas=openblas
--with-openssl=yes
--with-libiconv-prefix=$TERMUX_PREFIX
--disable-java
ac_cv_header_glob_h=no
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
gl_cv_have_weak=no
"

# FIXME: Diable for arm temporarily
TERMUX_PKG_BLACKLISTED_ARCHES="arm"

source $TERMUX_SCRIPTDIR/common-files/setup_toolchain_gcc.sh

termux_step_post_get_source() {
	# Version guard
	local ver_e=${TERMUX_PKG_VERSION#*:}
	local ver_x=$(. $TERMUX_SCRIPTDIR/tur/octave/build.sh; echo ${TERMUX_PKG_VERSION#*:})
	if [ "${ver_e}" != "${ver_x}" ]; then
		termux_error_exit "Version mismatch between octave and octave-x."
	fi
}

termux_step_pre_configure() {
	_setup_toolchain_ndk_gcc_11

	LDFLAGS+=" -Wl,-rpath,$TERMUX_PREFIX/lib/octave/${TERMUX_PKG_VERSION#*:}"

	# Use a wrapper to ignore `-static-openmp`
	local _bin="$TERMUX_PKG_TMPDIR/_fake_bin"
	mkdir -p $_bin
	local _tool=
	for _tool in CC CXX LD; do
		local _cmd="$(eval echo \${$_tool})"
		sed -e "s|@TERMUX_PREFIX@|${TERMUX_PREFIX}|g" \
			-e "s|@COMPILER@|$(command -v $_cmd)|g" \
			"$TERMUX_PKG_BUILDER_DIR"/wrapper.in \
			> $TERMUX_PKG_TMPDIR/_fake_bin/$(basename $_cmd)
		chmod +x $TERMUX_PKG_TMPDIR/_fake_bin/$(basename $_cmd)
	done
	export PATH="$TERMUX_PKG_TMPDIR/_fake_bin:$PATH"

	## This is to allow the build script find the `moc` on cross-build host
	# for Qt-GUI
	#export PATH+=":${TERMUX_PREFIX}/opt/qt/cross/bin"
}

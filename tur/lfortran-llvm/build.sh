TERMUX_PKG_HOMEPAGE=https://lfortran.org/
TERMUX_PKG_DESCRIPTION="A modern open-source interactive Fortran compiler"
TERMUX_PKG_LICENSE="BSD 3-Clause"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=0.15.0
TERMUX_PKG_SRCURL=https://gitlab.com/lfortran/lfortran.git
TERMUX_PKG_DEPENDS="libllvm-11, libc++, zlib"
TERMUX_PKG_SUGGESTS="libkokkos"
TERMUX_PKG_PROVIDES="lfortran"
TERMUX_PKG_REPLACES="lfortran"
TERMUX_PKG_CONFLICTS="lfortran"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DBUILD_SHARED_LIBS=ON
-DWITH_LLVM=yes
-DLLVM_DIR=$TERMUX_PREFIX/opt/libllvm-11/lib/cmake/llvm
"
TERMUX_PKG_HOSTBUILD=true

# ```
# [...]/src/lfortran/parser/parser_stype.h:97:1: error: static_assert failed
# due to requirement
# 'sizeof(LFortran::YYSTYPE) == sizeof(LFortran::Vec<LFortran::AST::ast_t *>)'
# static_assert(sizeof(YYSTYPE) == sizeof(Vec<AST::ast_t*>));
# ^             ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ```
# Furthermore libkokkos does not support ILP32
TERMUX_PKG_BLACKLISTED_ARCHES="arm, i686"

termux_step_host_build() {
	termux_setup_cmake

	( cd $TERMUX_PKG_SRCDIR && sh build0.sh )
	cmake $TERMUX_PKG_SRCDIR
	make -j $TERMUX_MAKE_PROCESSES
}

termux_step_pre_configure() {
	PATH=$TERMUX_PKG_HOSTBUILD_DIR/src/bin:$PATH

	( cd $TERMUX_PKG_SRCDIR && sh build0.sh )

	for f in fpmath.h math_private.h s_clog.c s_clogf.c s_cpowf.c; do
		cp $TERMUX_PKG_BUILDER_DIR/$f $TERMUX_PKG_SRCDIR/src/runtime/impure/
	done

	LDFLAGS+=" -lm"
}

termux_step_post_make_install() {
	# XXX: This file is used in cpp backend but not installed by the build system.
	# XXX: So is this an upstream issue?
	mkdir -p $PREFIX/share/lfortran/lib/impure
	cp ${TERMUX_PKG_SRCDIR}/src/runtime/impure/lfortran_intrinsics.h $PREFIX/share/lfortran/lib/impure
}

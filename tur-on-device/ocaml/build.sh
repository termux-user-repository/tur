TERMUX_PKG_HOMEPAGE=https://ocaml.org/
TERMUX_PKG_DESCRIPTION="Industrial strength programming language with an emphasis on expressive types and safety"
TERMUX_PKG_LICENSE="LGPL-2.1"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="5.5.0"
TERMUX_PKG_SRCURL="https://github.com/ocaml/ocaml/releases/download/${TERMUX_PKG_VERSION}/ocaml-${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=c018052c8264a3791a8f54f84179e6bcc78ed82eb889bacc2773df445259aed3
TERMUX_PKG_DEPENDS="clang, libandroid-shmem"
TERMUX_PKG_EXCLUDED_ARCHES="arm, i686"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
ac_cv_func_getentropy=no
ac_cv_func_getlogin_r=no
--mandir=$TERMUX_PREFIX/share/man
"

termux_step_pre_configure() {
	if [ "${TERMUX_ON_DEVICE_BUILD}" = false ]; then
		termux_error_exit "This package doesn't support cross-compiling."
	fi

	export AS="$CC -c"
	export ASPP="$CC -c"
	LDFLAGS+=" -landroid-shmem -lm"
}

termux_step_make() {
	make -j"${TERMUX_PKG_MAKE_PROCESSES}"
}

termux_step_make_install() {
	make install
}

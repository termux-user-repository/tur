TERMUX_PKG_HOMEPAGE=https://opam.ocaml.org/
TERMUX_PKG_DESCRIPTION="A source-based package manager for OCaml"
TERMUX_PKG_LICENSE="LGPL-2.1"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="2.6.1"
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL="https://github.com/ocaml/opam/releases/download/${TERMUX_PKG_VERSION}/opam-full-${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=ebbaffa4192e69d612d2c1a5fc5a15b32730322d7e34bc4456ad4076bb987007
TERMUX_PKG_DEPENDS="curl, git, ocaml, patch, tar, unzip"
TERMUX_PKG_BUILD_DEPENDS="ocaml-static"
TERMUX_PKG_EXCLUDED_ARCHES="arm, i686"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--with-vendored-deps
MAKE=make
--disable-static
"

termux_step_pre_configure() {
	if [ "${TERMUX_ON_DEVICE_BUILD}" = false ]; then
		termux_error_exit "This package doesn't support cross-compiling."
	fi
}

termux_step_make() {
	make -j"${TERMUX_PKG_MAKE_PROCESSES}"
}

termux_step_make_install() {
	make install
}

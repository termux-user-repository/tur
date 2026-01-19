TERMUX_PKG_HOMEPAGE=https://aws.amazon.com/cli
TERMUX_PKG_DESCRIPTION="Universal Command Line Interface for Amazon Web Services"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="2.32.28"
TERMUX_PKG_SRCURL="https://github.com/aws/aws-cli/archive/refs/tags/$TERMUX_PKG_VERSION.tar.gz"
TERMUX_PKG_SHA256=85ecd5baf4d5cdf4d9e436dd76e023d0126cdcd0e5cbf97a5cd15b33f8829b05
TERMUX_PKG_UPDATE_VERSION_REGEXP="\d+.\d+.\d+"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_SETUP_PYTHON=true
TERMUX_PKG_DEPENDS="libffi, libsqlite, groff"
TERMUX_PKG_BUILD_DEPENDS="ldd"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--with-install-type=portable-exe
--with-download-deps
"
TERMUX_PKG_MAKE_PROCESSES=1

termux_step_pre_configure() {
	export LDFLAGS="$LDFLAGS -lm"
}

termux_step_make() {
	export PIP_NO_BINARY='awscrt'
	export AWS_CRT_BUILD_FORCE_STATIC_LIBS=1
	make
}

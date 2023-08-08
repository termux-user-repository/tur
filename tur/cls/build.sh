TERMUX_PKG_HOMEPAGE=https://deva.is-cool.dev/
TERMUX_PKG_DESCRIPTION="Adds The Command 'cls'"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=0.0.2
TERMUX_PKG_SRCURL=https://github.com/deSHELL/clspkg/archive/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=7c5e30105ee1255bdf59c73bd430f91301dc2e1de596c551682b411002cf4bfd
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
        termux_setup_cmake
}

termux_step_make() {
        cd $TERMUX_PKG_SRCDIR
}

termux_step_make_install() {
        install -Dm700 -t "${TERMUX_PREFIX}"/bin "$TERMUX_PKG_SRCDIR"/cls
}

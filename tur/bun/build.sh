TERMUX_PKG_HOMEPAGE=https://bun.sh/
_MAJOR_VERSION=1.0
TERMUX_PKG_DESCRIPTION="Incredibly fast JavaScript runtime, bundler, test runner, and package manager – all in one (version $_MAJOR_VERSION)"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@jothi-prasath"
TERMUX_PKG_VERSION=${_MAJOR_VERSION}.2
TERMUX_PKG_SRCURL=https://github.com/oven-sh/bun/releases/download/bun-v${TERMUX_PKG_VERSION}/bun-linux-aarch64.zip
TERMUX_PKG_SHA256=8b356d5b6f1013b4edcba0df4032a6c35a2a0f918ea254f309e2149ad808d54c
TERMUX_PKG_BUILD_DEPENDS="wget, bsdtar"

termux_step_make_install() {
  cp $TERMUX_PKG_SRCDIR/bun $PREFIX/bin
}


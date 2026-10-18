TERMUX_PKG_HOMEPAGE=https://github.com
TERMUX_PKG_DESCRIPTION="A fast, multi-threaded package manager for Termux written in Rust"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="lev73748 <lev384501@gmail.com>"
TERMUX_PKG_VERSION=0.5.4
TERMUX_PKG_SRCURL=https://github.com/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_BUILD_STYLE=cargo

# Note: Ensure that the version tag 'v0.5.4' is created in your personal repository releases,
# so the build system can successfully download the source code archive.

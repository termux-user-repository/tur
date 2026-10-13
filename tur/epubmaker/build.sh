TERMUX_PKG_HOMEPAGE=https://github.com/epubmaker-tui/epubmaker
TERMUX_PKG_DESCRIPTION="Minimal EPUB builder: epub.ini + .html -> EPUB 3.0, supports auto-scan"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="kam62869536-gif"
TERMUX_PKG_VERSION="1.0.0"
TERMUX_PKG_SRCURL=https://github.com/epubmaker-tui/epubmaker/archive/refs/tags/v1.0.0.tar.gz
TERMUX_PKG_DEPENDS="zip"
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_make() {
    clang++ -std=c++17 -O2 -Wall -o epubmaker epubmaker.cpp
}

termux_step_make_install() {
    install -Dm755 epubmaker "$TERMUX_PREFIX/bin/epubmaker"

}


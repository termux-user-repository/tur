TERMUX_PKG_HOMEPAGE="https://github.com/senyyds12345/Tokenizer"
TERMUX_PKG_DESCRIPTION="A high-performance tokenizer/lexer library for C++"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="senyyds <1494621359@qq.com>"
TERMUX_PKG_VERSION="1.0.0-stable"
TERMUX_PKG_SRCURL="https://github.com/senyyds12345/Tokenizer/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256="4ed2c136c5b1facde25a2d8af2adf086db74dbf9da431254a7614db4b6eeea07"
TERMUX_PKG_PLATFORM_INDEPENDENT=true
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_make_install() {
    install -Dm600 $TERMUX_PKG_SRCDIR/Token.hpp $TERMUX_PREFIX/include/Token/Token.hpp
    ln -sf $TERMUX_PREFIX/include/Token/Token.hpp $TERMUX_PREFIX/include/Token
}
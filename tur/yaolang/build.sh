# License: MIT
TERMUX_PKG_HOMEPAGE=https://yaolang.l.cd
TERMUX_PKG_DESCRIPTION="YaoLang - Programming language with 100% Chinese keywords"
TERMUX_PKG_MAINTAINER="@a737812"
TERMUX_PKG_VERSION=0.1.0
TERMUX_PKG_SRCURL=https://github.com/a737812/yaolang/archive/refs/heads/main.tar.gz
TERMUX_PKG_SHA256=SKIP
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_DEPENDS="clang"
termux_step_configure() { return 0; }
termux_step_make() {
    $CC -O2 -o yaolang src/yaolang.c -lm
}
termux_step_make_install() {
    install -Dm700 -T yaolang "$TERMUX_PREFIX/bin/yaolang"
}

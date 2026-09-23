TERMUX_PKG_HOMEPAGE=https://github.com/ivan1231545/cat-armv7
TERMUX_PKG_DESCRIPTION="ARM assembly cat utility for Termux"                                                TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_VERSION=1.0.0
TERMUX_PKG_SRCURL=https://github.com/ivan1231545/cat-armv7/archive/refs/tags/main.tar.gz
TERMUX_PKG_SHA256=49013f4a6957a21d8b4bd0b92a176c97617d538067b695010413d1d95a3ec958

termux_step_make_install() {
	# Копируем исходный файл .s в директорию сборки
	cp $TERMUX_PKG_SRCDIR/cat_armv7.s $TERMUX_BUILD_DIR/

	# Собираем бинарь
	clang --target=armv7a-linux-gnueabihf -nostdlib -static \
		-o $TERMUX_PREFIX/bin/cat_armv7 $TERMUX_BUILD_DIR/cat_armv7.s
}
https://github.com/ivan1231545/cat-armv7/archive/refs/tags/main.tar.gz

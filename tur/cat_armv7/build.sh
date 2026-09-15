TERMUX_PKG_HOMEPAGE=https://github.com/твой-ник/cat-armv7
TERMUX_PKG_DESCRIPTION="ARM assembly cat utility for Termux"                                                TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_VERSION=1.0.0
TERMUX_PKG_SRCURL=https://github.com/ivan1231545/cat-armv7/archive/refs/tags/v1.0.0.tar.gz
TERMUX_PKG_SHA256=73a94523fe34a046eed4aff72b5f9c130f515dad963c53ead99c8a39b90fb2af

termux_step_make_install() {
    # Копируем исходный файл .s в директорию сборки
    cp $TERMUX_PKG_SRCDIR/cat_armv7.s $TERMUX_BUILD_DIR/

    # Собираем бинарь
    clang --target=armv7a-linux-gnueabihf -nostdlib -static \
        -o $TERMUX_PREFIX/bin/cat_armv7 $TERMUX_BUILD_DIR/cat_armv7.s
}
https://github.com/ivan1231545/cat-armv7/archive/refs/tags/v1.0.0.tar.gz

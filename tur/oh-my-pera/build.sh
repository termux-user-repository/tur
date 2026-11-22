TERMUX_PKG_HOMEPAGE="https://github.com/mertcakh2-cmd/Oh-my-peraTur"
TERMUX_PKG_DESCRIPTION="Oh-my-pera Termux theme, startup configuration and Ohiya editor"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@mertcakh2-cmd"
TERMUX_PKG_VERSION="1.1.0"
TERMUX_PKG_SRCURL="git+https://github.com/mertcakh2-cmd/Oh-my-perA.git"
TERMUX_PKG_GIT_BRANCH="main"
TERMUX_PKG_DEPENDS="python"
TERMUX_PKG_PLATFORM_INDEPENDENT=true

termux_step_make_install() {
local data="$TERMUX_PREFIX/share/oh-my-pera"

if [ ! -d "$TERMUX_PKG_SRCDIR/.termux" ]; then
    termux_error_exit "Missing .termux directory in source repository"
fi

install -d "$data"
cp -a "$TERMUX_PKG_SRCDIR/.termux/." "$data/"

install -Dm755 "$TERMUX_PKG_BUILDER_DIR/oh-my-pera" \
    "$TERMUX_PREFIX/bin/oh-my-pera"

install -Dm755 "$TERMUX_PKG_BUILDER_DIR/ohiya" \
    "$TERMUX_PREFIX/bin/ohiya"

}

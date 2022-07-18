TERMUX_PKG_HOMEPAGE=https://github.com/KrutosVIP/TermuxInstall
TERMUX_PKG_DESCRIPTION="Install Termux to chroot from Termux"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@KrutosVIP"
TERMUX_PKG_VERSION="1.1.1"
TERMUX_PKG_SRCURL=https://github.com/KrutosVIP/TermuxInstall/archive/refs/tags/${TERMUX_PKG_VERSION}.zip
TERMUX_PKG_SHA256=e33d9561f80174ee94093212652168923244047e8b8c183a6b4035738c80d03d
TERMUX_PKG_DEPENDS="python, wget, proot"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_make_install() {
	install -Dm700 -t "${TERMUX_PREFIX}"/bin "$TERMUX_PKG_SRCDIR"/bin/*
}

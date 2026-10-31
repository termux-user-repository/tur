TERMUX_PKG_HOMEPAGE=https://github.com/M-Igashi/mp3rgain
TERMUX_PKG_DESCRIPTION="Lossless MP3 and AAC volume normalizer using ReplayGain, compatible with mp3gain"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@M-Igashi"
TERMUX_PKG_VERSION="3.15.0"
TERMUX_PKG_SRCURL="https://github.com/M-Igashi/mp3rgain/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=357eeab432f25b620010198814f1ec3c3fe1fe0ae3737c5792ed15ddbee739e6
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_pre_configure() {
	termux_setup_rust
}

termux_step_post_make_install() {
	install -Dm600 -t "${TERMUX_PREFIX}/share/man/man1" docs/man/mp3rgain.1
}

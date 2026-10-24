TERMUX_PKG_HOMEPAGE=https://github.com/M-Igashi/mp3rgain
TERMUX_PKG_DESCRIPTION="Lossless MP3 and AAC volume normalizer using ReplayGain, compatible with mp3gain"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@M-Igashi"
TERMUX_PKG_VERSION="3.12.1"
TERMUX_PKG_SRCURL="https://github.com/M-Igashi/mp3rgain/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=64c9c7c418861659b0af4216c285a99d34481dc4441fd7fdfed7f9a41dc7279f
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_pre_configure() {
	termux_setup_rust
}

termux_step_post_make_install() {
	install -Dm600 -t "${TERMUX_PREFIX}/share/man/man1" docs/man/mp3rgain.1
}

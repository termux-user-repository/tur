TERMUX_PKG_HOMEPAGE=https://github.com/stonxmg-lang/termux-ghost
TERMUX_PKG_DESCRIPTION="History autosuggestions for bash, like zsh-autosuggestions"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@stonxmg-lang"
TERMUX_PKG_VERSION="1.0.0"
TERMUX_PKG_SRCURL=https://github.com/stonxmg-lang/termux-ghost/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=605f0ce46f540ec854fe2c0afae37bee076a6996d9092e5829d5134cb3f8b9f0
TERMUX_PKG_DEPENDS="bash, readline"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_make_install() {
	make install PREFIX="$TERMUX_PREFIX"
}

termux_step_create_debscripts() {
	cat <<-EOF > ./postinst
	#!$TERMUX_PREFIX/bin/sh
	echo
	echo "bash-ghost: to turn it on, add this line to ~/.bashrc and open a new session:"
	echo '  [[ \$- == *i* ]] && enable -f "\$PREFIX/lib/bash/ghost" ghost 2>/dev/null'
	echo
	EOF
}

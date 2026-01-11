TERMUX_PKG_HOMEPAGE="https://github.com/fmang/opustags"
TERMUX_PKG_DESCRIPTION="A CLI utility for editing metadata tags of Ogg Opus file"
TERMUX_PKG_LICENSE="BSD 3-Clause"
TERMUX_PKG_MAINTAINER="@termux-user-repository, @flosnvjx"
TERMUX_PKG_VERSION="1.10.1+r13"
_COMMIT=37deeb32d345f56393cd5d9e4b1c23565de196bf
TERMUX_PKG_SRCURL="git+https://github.com/fmang/opustags"
TERMUX_PKG_SHA256=SKIP_CHECKSUM
TERMUX_PKG_GIT_BRANCH=master
TERMUX_PKG_DEPENDS="libogg, libiconv, libc++"

termux_step_post_get_source() {
	git checkout "$_COMMIT"
}

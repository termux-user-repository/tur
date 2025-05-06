TERMUX_PKG_HOMEPAGE=https://www.erlang.org/
TERMUX_PKG_DESCRIPTION="Prebuilt legacy manpages for Erlang"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="26.2.5.11"
TERMUX_PKG_SRCURL=https://github.com/erlang/otp/releases/download/OTP-${TERMUX_PKG_VERSION}/otp_doc_man_${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=601f401b948e767f7b7ff5e139cae9579ad20fba3862da4b8da388c7965290c3
TERMUX_PKG_SUGGESTS="erlang"
TERMUX_PKG_BUILD_DEPENDS="rsync"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_PLATFORM_INDEPENDENT=true

termux_step_make_install() {
	# conflicts with perl manpage
	rm man3/re.3
	# conflicts with zlib package
	rm man3/zlib.3
	# man1 directory still exists in Erlang 27.
	# Only Erlang 26 has man3/4/6/7, enabling "erl -man io" and similar commands.
	rsync -aI man{3,4,6,7} "$TERMUX_PREFIX/share/man/"
}

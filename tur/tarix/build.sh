TERMUX_PKG_HOMEPAGE=https://github.com/fastcat/tarix
TERMUX_PKG_DESCRIPTION="A helper utility for indexing tar archive to ease random access"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@flosnvjx, @termux-user-repository"
_COMMIT=0d3b98f2f5f0bb3b4f08c124c58c7dbcb92c659b
_COMMIT_DATE=20181129
TERMUX_PKG_VERSION="1.0.9-p$_COMMIT_DATE"
TERMUX_PKG_GIT_BRANCH=master
TERMUX_PKG_SRCURL="git+https://github.com/fastcat/tarix.git"
TERMUX_PKG_BUILD_DEPENDS="libfuse2"
TERMUX_PKG_DEPENDS="glib, zlib"
TERMUX_PKG_SUGGESTS="libfuse2"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_MAKE_INSTALL_TARGET="INSTBASE=$TERMUX_PREFIX install"

termux_step_post_get_source() {
	git fetch --unshallow
	git checkout $_COMMIT

	local pdate="p$(git log -1 --format=%cs | sed 's/-//g')"
	if [[ "$TERMUX_PKG_VERSION" != *"${pdate}" ]]; then
		echo -n "ERROR: The version string \"$TERMUX_PKG_VERSION\" is"
		echo -n " different from what is expected to be; should end"
		echo " with \"${pdate}\"."
		return 1
	fi

}
termux_step_make() {
	make CC="${CC:-cc}" CPPFLAGS="-I. -Isrc -D_GNU_SOURCE $CPPFLAGS" OPTCFLAGS="$CFLAGS -Wno-error=misleading-indentation" LDFLAGS="$LDFLAGS -lz"
}

termux_step_post_make_install() {
	install -Dm644 -t "$TERMUX_PREFIX/share/doc/$TERMUX_PKG_NAME" README BUGS CREDITS ChangeLog FORMAT Limitations QuickStart TODO Zlib
}

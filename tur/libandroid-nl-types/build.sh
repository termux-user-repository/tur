TERMUX_PKG_HOMEPAGE=https://android.googlesource.com/platform/bionic/+/refs/heads/master/libc/bionic/nl_types.cpp
TERMUX_PKG_DESCRIPTION="Shared library for catopen/catgets/catclose of Bionic Libc"
TERMUX_PKG_LICENSE="BSD 2-Clause"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_SRCURL="https://android.googlesource.com/platform/bionic/+/refs/heads/master/libc/bionic/nl_types.cpp"
TERMUX_PKG_SHA256=SKIP_CHECKSUM
TERMUX_PKG_VERSION=0.1
TERMUX_PKG_REVISION=1
TERMUX_PKG_SKIP_SRC_EXTRACT=true
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_get_source() {
	mkdir -p $TERMUX_PKG_SRCDIR
	cd $TERMUX_PKG_SRCDIR

	curl "$TERMUX_PKG_SRCURL?format=text" | base64 -d > nl_types.cpp
}

# Files are taken from the Bionic libc repo.
# nl_types.cpp: https://android.googlesource.com/platform/bionic/+/refs/heads/master/libc/bionic/nl_types.cpp
termux_step_make() {
	$CXX $CFLAGS $CPPFLAGS -I$TERMUX_PKG_BUILDER_DIR -c nl_types.cpp
	$CXX $LDFLAGS -shared nl_types.o -o libandroid-nl-types.so
	$AR rcu libandroid-nl-types.a nl_types.o
	cp -f $TERMUX_PKG_BUILDER_DIR/LICENSE $TERMUX_PKG_SRCDIR
}

termux_step_make_install() {
	install -Dm600 libandroid-nl-types.a $TERMUX_PREFIX/lib/libandroid-nl-types.a
	install -Dm600 libandroid-nl-types.so $TERMUX_PREFIX/lib/libandroid-nl-types.so
}

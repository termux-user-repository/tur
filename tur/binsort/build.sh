TERMUX_PKG_HOMEPAGE="http://neoscientists.org/~tmueller/binsort/"
TERMUX_PKG_DESCRIPTION="Sort files by binary similarity"
TERMUX_PKG_LICENSE="BSD 3-Clause"
TERMUX_PKG_LICENSE_FILE="COPYRIGHT"
TERMUX_PKG_MAINTAINER="@flosnvjx"
TERMUX_PKG_VERSION=0.4
TERMUX_PKG_SRCURL="http://neoscientists.org/~tmueller/binsort/download/binsort-$TERMUX_PKG_VERSION-1.tar.gz"
TERMUX_PKG_SHA256=97d4f42e50ec9710a06587fc36b6ec465cbb6d110e4c6c29b4bb5e7a0dd33518
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_make() {
	find * -maxdepth 0 -type f -print \
		| xargs install -vDm600 -t binsort0
	## create separate binary "binsort0" with behaviour like find -print0
	sed -e 's@printf("%s\\n", entry->den_Name);@printf("%s", entry->den_Name);putchar(0);@' -i binsort0/binsort.c
	local br; for br in . binsort0; do
		make -C $br CC=${CC} LD=$LD PREFIX=$TERMUX_PREFIX OPT="-std=gnu99 $CFLAGS $CPPFLAGS" PLATFORM_LIBS="$LDFLAGS -lpthread -lm"
	done
}

termux_step_make_install() {
	install -Dm700 -t $TERMUX_PREFIX/bin binsort
	install -Dm700 -T binsort0/binsort $TERMUX_PREFIX/bin/binsort0
	install -Dm600 -t $TERMUX_PREFIX/share/doc/$TERMUX_PKG_NAME README
}

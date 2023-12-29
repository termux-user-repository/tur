TERMUX_PKG_HOMEPAGE=https://github.com/AndreRH/qemu
TERMUX_PKG_DESCRIPTION="x86 and x86-64 Linux emulator library for Hangover"
TERMUX_PKG_LICENSE="custom"
TERMUX_PKG_LICENSE_FILE="LICENSE, COPYING, COPYING.LIB"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
_COMMIT="547c80c2ab9e3165fcf29b51064f668198aae520"
_COMMIT_DATE=2023.07.30
TERMUX_PKG_VERSION=8.17
TERMUX_PKG_SRCURL=git+https://github.com/AndreRH/qemu
TERMUX_PKG_GIT_BRANCH="wow"
TERMUX_PKG_DEPENDS="glib, libandroid-shmem"

# Required by configuration script, but I can't find any binary that uses it.
TERMUX_PKG_BUILD_DEPENDS="libtasn1"

TERMUX_PKG_BLACKLISTED_ARCHES="arm, i686, x86_64"
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_get_source() {
	local TMP_CHECKOUT=$TERMUX_PKG_CACHEDIR/tmp-checkout
	local TMP_CHECKOUT_VERSION=$TERMUX_PKG_CACHEDIR/tmp-checkout-version

	if [ ! -f $TMP_CHECKOUT_VERSION ] || [ "$(cat $TMP_CHECKOUT_VERSION)" != "$TERMUX_PKG_VERSION" ]; then
		rm -rf $TMP_CHECKOUT
		git clone \
			--branch $TERMUX_PKG_GIT_BRANCH \
			${TERMUX_PKG_SRCURL:4} \
			$TMP_CHECKOUT

		pushd $TMP_CHECKOUT
		git submodule update --init --recursive
		popd

		echo "$TERMUX_PKG_VERSION" > $TMP_CHECKOUT_VERSION
	fi

	rm -rf $TERMUX_PKG_SRCDIR
	cp -Rf $TMP_CHECKOUT $TERMUX_PKG_SRCDIR
	cp -Rf $TMP_CHECKOUT/.git $TERMUX_PKG_SRCDIR/

	cd $TERMUX_PKG_SRCDIR

	git checkout $_COMMIT
	git submodule update --init --recursive
	local commit_date="$(git log -1 --format=%cs | sed 's/-/./g')"
	if [ "$commit_date" != "$_COMMIT_DATE" ]; then
		echo -n "ERROR: The specified commit date \"$_COMMIT_DATE\""
		echo " is different from what is expected to be: \"$commit_date\""
		return 1
	fi
}

termux_step_pre_configure() {
	# Workaround for https://github.com/termux/termux-packages/issues/12261.
	if [ $TERMUX_ARCH = "aarch64" ]; then
		rm -f $TERMUX_PKG_BUILDDIR/_lib
		mkdir -p $TERMUX_PKG_BUILDDIR/_lib

		cd $TERMUX_PKG_BUILDDIR
		mkdir -p _setjmp-aarch64
		pushd _setjmp-aarch64
		mkdir -p private
		local s
		for s in $TERMUX_PKG_BUILDER_DIR/setjmp-aarch64/{setjmp.S,private-*.h}; do
			local f=$(basename ${s})
			cp ${s} ./${f/-//}
		done
		$CC $CFLAGS $CPPFLAGS -I. setjmp.S -c
		$AR cru $TERMUX_PKG_BUILDDIR/_lib/libandroid-setjmp.a setjmp.o
		popd

		LDFLAGS+=" -L$TERMUX_PKG_BUILDDIR/_lib -l:libandroid-setjmp.a"
	fi
}

termux_step_configure() {
	termux_setup_ninja

	if [ "$TERMUX_ARCH" = "i686" ]; then
		LDFLAGS+=" -latomic"
	fi

	CFLAGS+=" $CPPFLAGS"
	CXXFLAGS+=" $CPPFLAGS"
	LDFLAGS+=" -landroid-shmem -llog"

	# Note: using --disable-stack-protector since stack protector
	# flags already passed by build scripts but we do not want to
	# override them with what QEMU configure provides.
	./configure \
		--prefix="$TERMUX_PREFIX" \
		--cross-prefix="${TERMUX_HOST_PLATFORM}-" \
		--host-cc="gcc" \
		--cc="$CC" \
		--cxx="$CXX" \
		--objcc="$CC" \
		--disable-stack-protector \
		--enable-coroutine-pool \
		--enable-trace-backends=nop \
		--disable-werror \
		--disable-guest-agent \
		--disable-sdl \
		--disable-sdl-image \
		--disable-gtk \
		--disable-vte \
		--disable-vnc-sasl \
		--disable-xen \
		--disable-xen-pci-passthrough \
		--disable-hax \
		--disable-hvf \
		--disable-whpx \
		--disable-snappy \
		--disable-lzfse \
		--disable-seccomp \
		--disable-parallels \
		--disable-vhost-user \
		--disable-vhost-user-blk-server \
		--target-list="arm-linux-user,i386-linux-user"
}

termux_step_make() {
	make -j $TERMUX_MAKE_PROCESSES || bash
}

termux_step_make_install() {
	cp ./build/libqemu-arm.so $TERMUX_PREFIX/lib/
	cp ./build/libqemu-i386.so $TERMUX_PREFIX/lib/
}

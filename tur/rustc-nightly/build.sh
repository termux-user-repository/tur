TERMUX_PKG_HOMEPAGE=https://www.rust-lang.org
TERMUX_PKG_DESCRIPTION="Rust compiler and utilities (nightly version)"
TERMUX_PKG_DEPENDS="libc++, clang, openssl, lld, zlib, libllvm"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
_DATE="2023-02-27"
TERMUX_PKG_VERSION="1.67.1-${_DATE//-/.}-nightly"
TERMUX_PKG_SRCURL=https://static.rust-lang.org/dist/$_DATE/rustc-nightly-src.tar.xz
TERMUX_PKG_SHA256=ceb53d6a8cc18434efa3093e3debe5484dde8201dcba4fdbe83e83f32b8dad74
TERMUX_PKG_RM_AFTER_INSTALL="bin/llvm-* bin/llc bin/opt"

termux_step_pre_configure() {
	termux_setup_cmake

	export RUST_LIBDIR=$TERMUX_PKG_BUILDDIR/_lib
	mkdir -p $RUST_LIBDIR

	export LLVM_VERSION=$(. $TERMUX_SCRIPTDIR/packages/libllvm/build.sh; echo $TERMUX_PKG_VERSION)
	export LZMA_VERSION=$(. $TERMUX_SCRIPTDIR/packages/liblzma/build.sh; echo $TERMUX_PKG_VERSION)

	# we can't use -L$PREFIX/lib since it breaks things but we need to link against libLLVM-9.so
	ln -sf $PREFIX/lib/libLLVM-${LLVM_VERSION/.*/}.so $RUST_LIBDIR
	ln -sf $PREFIX/lib/libLLVM-$LLVM_VERSION.so $RUST_LIBDIR

	# rust tries to find static library 'c++_shared'
	ln -sf $TERMUX_STANDALONE_TOOLCHAIN/sysroot/usr/lib/$TERMUX_HOST_PLATFORM/libc++_static.a \
		$RUST_LIBDIR/libc++_shared.a

	# https://github.com/termux/termux-packages/issues/11640
	# https://github.com/termux/termux-packages/issues/11658
	# The build system somehow tries to link binaries against a wrong libc,
	# leading to build failures for arm and runtime errors for others.
	# The following command is equivalent to
	#	ln -sft $RUST_LIBDIR \
	#		$TERMUX_STANDALONE_TOOLCHAIN/sysroot/usr/lib/$TERMUX_HOST_PLATFORM/$TERMUX_PKG_API_LEVEL/lib{c,dl}.so
	# but written in a future-proof manner.
	ln -sft $RUST_LIBDIR $(echo | $CC -x c - -Wl,-t -shared | grep '\.so$')

	# rust checks libs in PREFIX/lib. It then can't find libc.so and libdl.so because rust program doesn't
	# know where those are. Putting them temporarly in $PREFIX/lib prevents that failure
	mv $TERMUX_PREFIX/lib/libtinfo.so.6 $TERMUX_PREFIX/lib/libtinfo.so.6.tmp
	mv $TERMUX_PREFIX/lib/libz.so.1 $TERMUX_PREFIX/lib/libz.so.1.tmp
	mv $TERMUX_PREFIX/lib/libz.so $TERMUX_PREFIX/lib/libz.so.tmp
	mv $TERMUX_PREFIX/lib/liblzma.so.$LZMA_VERSION $TERMUX_PREFIX/lib/liblzma.so.tmp

	# https://github.com/termux/termux-packages/issues/11427
	# Fresh build conflict: liblzma -> rust
	# ld: error: /data/data/com.termux/files/usr/lib/liblzma.a(liblzma_la-common.o) is incompatible with elf64-x86-64
	mv $TERMUX_PREFIX/lib/liblzma.a $TERMUX_PREFIX/lib/liblzma.a.tmp || true

	# ld: error: undefined symbol: getloadavg
	# >>> referenced by rand.c
	$CC $CPPFLAGS -c $TERMUX_PKG_BUILDER_DIR/getloadavg.c
	$AR rcu $RUST_LIBDIR/libgetloadavg.a getloadavg.o
}


termux_step_configure() {
	env -i PATH="$PATH" sudo apt update
	env -i PATH="$PATH" sudo apt install llvm-14 -yq

	case $TERMUX_ARCH in
	    "aarch64" ) CARGO_TARGET_NAME=aarch64-linux-android ;;
	    "arm" ) CARGO_TARGET_NAME=armv7-linux-androideabi ;;
	    "i686" ) CARGO_TARGET_NAME=i686-linux-android ;;
	    "x86_64" ) CARGO_TARGET_NAME=x86_64-linux-android ;;
	esac

	export RUST_BACKTRACE=1
	mkdir -p $TERMUX_PREFIX/opt/rust-nightly
	RUST_PREFIX=$TERMUX_PREFIX/opt/rust-nightly
	export PATH=$TERMUX_PKG_TMPDIR/bin:$PATH
	sed $TERMUX_PKG_BUILDER_DIR/config.toml \
		-e "s|@RUST_PREFIX@|$RUST_PREFIX|g" \
		-e "s|@TERMUX_PREFIX@|$TERMUX_PREFIX|g" \
		-e "s|@TERMUX_HOST_PLATFORM@|$TERMUX_HOST_PLATFORM|g" \
		-e "s|@TERMUX_STANDALONE_TOOLCHAIN@|$TERMUX_STANDALONE_TOOLCHAIN|g" \
		-e "s|@BUILD_LLVM_CONFIG@|$(command -v llvm-config-14)|g" \
		-e "s|@RUST_TARGET_TRIPLE@|$CARGO_TARGET_NAME|g" > $TERMUX_PKG_BUILDDIR/config.toml

	local ENV_NAME=CARGO_TARGET_${CARGO_TARGET_NAME^^}_LINKER
	ENV_NAME=${ENV_NAME//-/_}
	export $ENV_NAME=$CC
	export TARGET_CFLAGS="--target=$CCTERMUX_HOST_PLATFORM ${CFLAGS-} $CPPFLAGS"

	export RUSTFLAGS="-C link-arg=-Wl,-rpath=$RUST_PREFIX/lib $RUSTFLAGS"

	export X86_64_UNKNOWN_LINUX_GNU_OPENSSL_LIB_DIR=/usr/lib/x86_64-linux-gnu
	export X86_64_UNKNOWN_LINUX_GNU_OPENSSL_INCLUDE_DIR=/usr/include
	export PKG_CONFIG_ALLOW_CROSS=1

	# for backtrace-sys
	export CC_x86_64_unknown_linux_gnu=gcc
	export CFLAGS_x86_64_unknown_linux_gnu="-O2"
	export LLVM_VERSION=$(. $TERMUX_SCRIPTDIR/packages/libllvm/build.sh; echo $TERMUX_PKG_VERSION)
}

termux_step_make() {
	:
}

termux_step_make_install() {
	unset CC CXX CPP LD CFLAGS CXXFLAGS CPPFLAGS LDFLAGS PKG_CONFIG AR RANLIB
	../src/x.py install --host $CARGO_TARGET_NAME --target $CARGO_TARGET_NAME --target wasm32-unknown-unknown || bash
}

termux_step_post_make_install() {
	mkdir -p $TERMUX_PREFIX/etc/profile.d
	mkdir -p $TERMUX_PREFIX/lib
	echo "#!$TERMUX_PREFIX/bin/sh" > $TERMUX_PREFIX/etc/profile.d/rust-nightly.sh
	echo "export PATH=$RUST_PREFIX/bin:\$PATH" >> $TERMUX_PREFIX/etc/profile.d/rust-nightly.sh

	ln -sf $TERMUX_PREFIX/bin/lld $RUST_PREFIX/bin/rust-lld
}

termux_step_post_massage() {
	rm -f lib/libtinfo.so.6
	rm -f lib/libz.so
	rm -f lib/libz.so.1
	rm -f lib/liblzma.so.$LZMA_VERSION
	rm -f lib/liblzma.a
	rm -f lib/*.tmp
}

termux_step_create_debscripts() {
	echo "#!$TERMUX_PREFIX/bin/sh" > postinst
	echo "echo 'source \$PREFIX/etc/profile.d/rust-nightly.sh to use nightly'" >> postinst
	echo "echo 'or export RUSTC=\$PREFIX/opt/rust-nightly/bin/rustc'" >> postinst
}

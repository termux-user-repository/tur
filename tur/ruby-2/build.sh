# Based on https://github.com/termux/termux-packages/tree/023f195fe7f101093fad083957a73c71cf6ffdf5/packages/ruby
TERMUX_PKG_HOMEPAGE=https://www.ruby-lang.org/
TERMUX_PKG_DESCRIPTION="Dynamic programming language with a focus on simplicity and productivity (Version 2)"
TERMUX_PKG_LICENSE="BSD 2-Clause"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=2.7.6
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=https://cache.ruby-lang.org/pub/ruby/${TERMUX_PKG_VERSION:0:3}/ruby-${TERMUX_PKG_VERSION}.tar.xz
TERMUX_PKG_SHA256=54dcd3044726c4ab75a9d4604720501442b229a3aed6a55fe909567da8807f24
# libbffi is used by the fiddle extension module:
TERMUX_PKG_DEPENDS="gdbm, libandroid-support, libffi, libgmp, readline, openssl-1.1, libyaml, zlib"
TERMUX_PKG_RECOMMENDS="clang, make, pkg-config"
TERMUX_PKG_BREAKS="ruby-dev"
TERMUX_PKG_REPLACES="ruby-dev"
# Needed to fix compilation on android:
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
ac_cv_func_setgroups=no
ac_cv_func_setresuid=no
ac_cv_func_setreuid=no
--enable-rubygems
--with-coroutine=copy
--prefix=$TERMUX_PREFIX/opt/ruby-2
--program-suffix=-2"
# The gdbm module seems to be very little used:
TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" --without-gdbm"
# Do not link in libcrypt.so if available (now in disabled-packages):
TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" ac_cv_lib_crypt_crypt=no"
# Fix DEPRECATED_TYPE macro clang compatibility:
TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" rb_cv_type_deprecated=x"
# getresuid(2) does not work on ChromeOS - https://github.com/termux/termux-app/issues/147:
# TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" ac_cv_func_getresuid=no"
TERMUX_PKG_HOSTBUILD=true

termux_step_host_build() {
	# Need libssl1.1 to build ruby on host
	local _SSL_SRCURL=https://www.openssl.org/source/openssl-1.1.1q.tar.gz
	local _SSL_SHA256=d7939ce614029cdff0b6c20f0e2e5703158a489a72b2507b8bd51bf8c8fd10ca
	local _SSL_TARFILE=$TERMUX_PKG_CACHEDIR/openssl-1.1.1q.tar.gz
	termux_download $_SSL_SRCURL $_SSL_TARFILE $_SSL_SHA256
	tar xf $_SSL_TARFILE
	pushd openssl-1.1.1q
	./config --prefix=$TERMUX_PKG_HOSTBUILD_DIR/ruby-host-openssl \
			--openssldir=$TERMUX_PKG_HOSTBUILD_DIR/ruby-host-openssl \
			shared zlib
	make -j $TERMUX_PKG_MAKE_PROCESSES
	make install
	popd

	"$TERMUX_PKG_SRCDIR/configure" \
			--prefix=$TERMUX_PKG_HOSTBUILD_DIR/ruby-host \
			--with-openssl-dir=$TERMUX_PKG_HOSTBUILD_DIR/ruby-host-openssl
	make -j $TERMUX_PKG_MAKE_PROCESSES
	make install
}

termux_step_pre_configure() {
	export PATH=$TERMUX_PKG_HOSTBUILD_DIR/ruby-host/bin:$PATH

	if [ "$TERMUX_ARCH_BITS" = 32 ]; then
		# process.c:function timetick2integer: error: undefined reference to '__mulodi4'
		TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" rb_cv_builtin___builtin_mul_overflow=no"
	fi

	# Do not remove: fix for Clang's "overoptimization".
	CFLAGS=${CFLAGS/-Oz/-O2}

	# Fix for openssl-1.1:
	mkdir -p $TERMUX_PREFIX/opt/ruby-2/openssl-1.1
	ln -s $TERMUX_PREFIX/include/openssl-1.1 $TERMUX_PREFIX/opt/ruby-2/openssl-1.1/include
	ln -s $TERMUX_PREFIX/lib/openssl-1.1 $TERMUX_PREFIX/opt/ruby-2/openssl-1.1/lib
	TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" --with-openssl-dir=$TERMUX_PREFIX/opt/ruby-2/openssl-1.1"
	CFLAGS+=" -I$TERMUX_PREFIX/include/openssl-1.1"
	LDFLAGS+=" -Wl,-rpath=$TERMUX_PREFIX/lib/openssl-1.1"
}

termux_step_make_install() {
	make install
	make uninstall # remove possible remains to get fresh timestamps
	make install

	local RBCONFIG=$TERMUX_PREFIX/lib/ruby/${TERMUX_PKG_VERSION:0:3}.0/${TERMUX_HOST_PLATFORM}/rbconfig.rb

	# Fix absolute paths to executables:
	perl -p -i -e 's/^.*CONFIG\["INSTALL"\].*$/  CONFIG["INSTALL"] = "install -c"/' $RBCONFIG
	perl -p -i -e 's/^.*CONFIG\["PKG_CONFIG"\].*$/  CONFIG["PKG_CONFIG"] = "pkg-config"/' $RBCONFIG
	perl -p -i -e 's/^.*CONFIG\["MAKEDIRS"\].*$/  CONFIG["MAKEDIRS"] = "mkdir -p"/' $RBCONFIG
	perl -p -i -e 's/^.*CONFIG\["MKDIR_P"\].*$/  CONFIG["MKDIR_P"] = "mkdir -p"/' $RBCONFIG
	perl -p -i -e 's/^.*CONFIG\["EGREP"\].*$/  CONFIG["EGREP"] = "grep -E"/' $RBCONFIG
	perl -p -i -e 's/^.*CONFIG\["GREP"\].*$/  CONFIG["GREP"] = "grep"/' $RBCONFIG
	perl -p -i -e 's|^.*CONFIG\["bindir"\] = .*$|  CONFIG["bindir"] = \"'"$TERMUX_PREFIX"'\"|' $RBCONFIG

	for i in bundle bundler erb gem irb racc racc2y rake rdoc ruby y2racc ; do
		ln -sr $TERMUX_PREFIX/opt/ruby-2/bin/$i-2 $TERMUX_PREFIX/bin/$i-2
		ln -sr $TERMUX_PREFIX/bin/$i-2 $TERMUX_PREFIX/bin/$i
	done
}

termux_step_post_massage() {
	if [ ! -f $TERMUX_PREFIX/lib/ruby/${TERMUX_PKG_VERSION:0:3}.0/${TERMUX_HOST_PLATFORM}/readline.so ]; then
		echo "Error: The readline extension was not built"
	fi
}

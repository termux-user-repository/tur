TERMUX_PKG_HOMEPAGE=https://php.net
TERMUX_PKG_DESCRIPTION="Server-side, HTML-embedded scripting language"
TERMUX_PKG_LICENSE="PHP-3.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=7.2.34
TERMUX_PKG_REVISION=1
TERMUX_PKG_SHA256=409e11bc6a2c18707dfc44bc61c820ddfd81e17481470f3405ee7822d8379903
TERMUX_PKG_SRCURL=https://secure.php.net/distributions/php-${TERMUX_PKG_VERSION}.tar.xz
# Build native php for phar to build (see pear-Makefile.frag.patch):
TERMUX_PKG_HOSTBUILD=true
# Build the native php without xml support as we only need phar:
TERMUX_PKG_EXTRA_HOSTBUILD_CONFIGURE_ARGS="--disable-libxml --disable-dom --disable-simplexml --disable-xml --disable-xmlreader --disable-xmlwriter --without-pear"
TERMUX_PKG_DEPENDS="libandroid-glob, libxml2, liblzma, openssl-1.1, pcre, libbz2, libcrypt, libcurl, libgd, readline, freetype, postgresql, apache2"
# mysql modules were initially shared libs
TERMUX_PKG_CONFLICTS="php, php7"
TERMUX_PKG_REPLACES="php, php7"
TERMUX_PKG_RM_AFTER_INSTALL="php/php/fpm"

TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
ac_cv_func_res_nsearch=no
--enable-bcmath
--enable-calendar
--enable-exif
--enable-gd-native-ttf=$TERMUX_PREFIX
--enable-mbstring
--enable-opcache
--enable-pcntl
--enable-sockets
--enable-zip
--mandir=$TERMUX_PREFIX/share/man
--with-bz2=$TERMUX_PREFIX
--with-curl=$TERMUX_PREFIX
--with-freetype-dir=$TERMUX_PREFIX
--with-gd=$TERMUX_PREFIX
--with-iconv=$TERMUX_PREFIX
--with-libxml-dir=$TERMUX_PREFIX
--with-openssl=$TERMUX_PREFIX
--with-pcre-regex=$TERMUX_PREFIX
--with-png-dir=$TERMUX_PREFIX
--with-readline=$TERMUX_PREFIX
--with-zlib
--with-pgsql=shared,$TERMUX_PREFIX
--with-pdo-pgsql=shared,$TERMUX_PREFIX
--with-mysqli=mysqlnd
--with-pdo-mysql=mysqlnd
--with-mysql-sock=$TERMUX_PREFIX/tmp/mysqld.sock
--with-apxs2=$TERMUX_PKG_TMPDIR/apxs-wrapper.sh
--enable-fpm
--sbindir=$TERMUX_PREFIX/bin
"

termux_step_host_build() {
	(cd "$TERMUX_PKG_SRCDIR" && ./buildconf --force)
	"$TERMUX_PKG_SRCDIR/configure" ${TERMUX_PKG_EXTRA_HOSTBUILD_CONFIGURE_ARGS}
	make -j "$TERMUX_PKG_MAKE_PROCESSES"
}

termux_step_pre_configure() {
	CPPFLAGS+=" -DGD_FLIP_VERTICAL=1"
	CPPFLAGS+=" -DGD_FLIP_HORINZONTAL=2"
	CPPFLAGS+=" -DGD_FLIP_BOTH=3"
	CPPFLAGS+=" -DU_DEFINE_FALSE_AND_TRUE=1"
	CPPFLAGS+=" -Wno-implicit-function-declaration"
	CPPFLAGS+=" -Wno-incompatible-function-pointer-types"

	if [ "$TERMUX_ARCH" = "aarch64" ]; then
		CFLAGS+=" -march=armv8-a+crc"
		CXXFLAGS+=" -march=armv8-a+crc"
	fi

	LDFLAGS+=" -landroid-glob -llog"

	export PATH="$PATH:$TERMUX_PKG_HOSTBUILD_DIR/sapi/cli/"
	export NATIVE_PHP_EXECUTABLE=$TERMUX_PKG_HOSTBUILD_DIR/sapi/cli/php

	# Run autoconf since we have patched config.m4 files.
	./buildconf --force

	export EXTENSION_DIR=$TERMUX_PREFIX/lib/php

	# Use a wrapper since bin/apxs has the Termux shebang:
	echo "perl $TERMUX_PREFIX/bin/apxs \$@" > $TERMUX_PKG_TMPDIR/apxs-wrapper.sh
	chmod +x $TERMUX_PKG_TMPDIR/apxs-wrapper.sh
	cat $TERMUX_PKG_TMPDIR/apxs-wrapper.sh
	CFLAGS="-I$TERMUX_PREFIX/include/openssl-1.1 $CFLAGS"
	CPPFLAGS="-I$TERMUX_PREFIX/include/openssl-1.1 $CPPFLAGS"
	CXXFLAGS="-I$TERMUX_PREFIX/include/openssl-1.1 $CXXFLAGS"
	LDFLAGS="-L$TERMUX_PREFIX/lib/openssl-1.1 -Wl,-rpath=$TERMUX_PREFIX/lib/openssl-1.1 $LDFLAGS"

	# Fix build with openssl-1.1
	export PKG_CONFIG_PATH=$PKG_CONFIG_LIBDIR
	export PKG_CONFIG_LIBDIR=$TERMUX_PREFIX/lib/openssl-1.1/pkgconfig

	local wrapper_bin=$TERMUX_PKG_BUILDDIR/_wrapper/bin
	local _cc=$(basename $CC)
	rm -rf $wrapper_bin
	mkdir -p $wrapper_bin
	cat <<-EOF > $wrapper_bin/$_cc
		#!$(command -v sh)
		exec $(command -v $_cc) -L$TERMUX_PREFIX/lib/openssl-1.1 \
			-Wno-unused-command-line-argument "\$@"
	EOF
	chmod 0700 $wrapper_bin/$_cc
	export PATH="$wrapper_bin:$PATH"
}

termux_step_post_configure() {
	# Avoid src/ext/gd/gd.c trying to include <X11/xpm.h>:
	sed -i 's/#define HAVE_GD_XPM 1//' $TERMUX_PKG_BUILDDIR/main/php_config.h
	# Avoid src/ext/standard/dns.c trying to use struct __res_state:
	sed -i 's/#define HAVE_RES_NSEARCH 1//' $TERMUX_PKG_BUILDDIR/main/php_config.h
	# Do not know where get `-I/usr/include`, remove it
	sed -i 's|-I/usr/include ||g' $TERMUX_PKG_BUILDDIR/Makefile
}

termux_step_post_make_install() {
	mkdir -p $TERMUX_PREFIX/etc/php-fpm.d
	cp sapi/fpm/php-fpm.conf $TERMUX_PREFIX/etc/
	cp sapi/fpm/www.conf $TERMUX_PREFIX/etc/php-fpm.d/

	sed -i 's/SED=.*/SED=sed/' $TERMUX_PREFIX/bin/phpize
}

termux_step_create_debscripts() {
	cat <<-EOF > ./postinst
		#!$TERMUX_PREFIX/bin/sh
		echo
		echo "********"
		echo "PHP 7.2 reaches its end of life and is no longer supported afterwards."
		echo "Please consider migrating to a newer version of PHP."
		echo "********"
		echo
	EOF
}

TERMUX_PKG_HOMEPAGE=http://www.garloff.de/kurt/linux/ddrescue/
TERMUX_PKG_DESCRIPTION="A dd(1) alternative without POSIX-correctness burden to ease daily shell scripting and data recovery"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_LICENSE_FILE="COPYING"
TERMUX_PKG_MAINTAINER="@flosnvjx"
TERMUX_PKG_VERSION="1.99.22"
TERMUX_PKG_SRCURL="https://garloff.de/kurt/linux/ddrescue/dd_rescue-${TERMUX_PKG_VERSION}.tar.bz2"
TERMUX_PKG_SHA256=c15fbfce24a2bf316b5ae795d891f84e7e5ddb583ba2886a55387f40ae767041
TERMUX_PKG_AUTO_UPDATE=false
TERMUX_PKG_UPDATE_METHOD=repology
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_EXTRA_MAKE_ARGS="
prefix=$TERMUX_PREFIX
INSTASROOT=
LIBDIR=$TERMUX_PREFIX/lib
LIB=lib
IGNORE_TARGET=1
"
TERMUX_PKG_MAKE_PROCESSES=1

termux_step_pre_configure() {
	## see also: https://gitweb.gentoo.org/repo/gentoo.git/tree/sys-fs/dd-rescue/dd-rescue-9999.ebuild

	TERMUX_PKG_EXTRA_CONFIGURE_ARGS+="
		ac_cv_header_lzo_lzo1x_h=no
		ac_cv_lib_lzo2_lzo1x_1_compress=no
		ac_cv_header_lzma_h=no
		ac_cv_lib_lzma_lzma_easy_encoder=no
		ac_cv_header_openssl_evp_h=no
		ac_cv_lib_crypto_EVP_aes_192_ctr=no
	"
	TERMUX_PKG_EXTRA_MAKE_ARGS+=' HAVE_LZMA=0 HAVE_OPENSSL=0 HAVE_LZO=0'

	sed -i \
		-e 's:\(-ldl\):$(LDFLAGS) \1:' \
		-e 's:\(-shared\):$(CFLAGS) $(LDFLAGS) \1:' \
		Makefile
	case "$TERMUX_ARCH" in
		(*) TERMUX_PKG_EXTRA_MAKE_ARGS+=" CC=$CC" ;;&
		(aarch64) TERMUX_PKG_EXTRA_MAKE_ARGS+=" MACH=$TERMUX_ARCH" ;;
		(arm) EXTRA_CFLAGS+=' -D__WORDSIZE=32'
		## v1.99.22: mask `hash` plugin since I could not get it to build on arm
		TERMUX_PKG_EXTRA_MAKE_ARGS+=' LIBTARGETS=libddr_null.so MACH=armv7'
		sed -e '/^\.SS hash$/,/^\.SH EXIT STATUS$/d
			/^\.BI dd_rescue\\ \\-ATL\\ hash=md5:output,lzo=compress:bench,MD5:output\\ in\\ out\.lzo$/,/^infile nor to write the checksum to CHECKSUMS.sha512.$/d' -i dd_rescue.1
		perl -0pe 's%^(On successful completion,)$%\n.SH EXIT STATUS\n\1%gms' < dd_rescue.1 > man.tmp
		mv man.tmp dd_rescue.1
		;;
		(i686) TERMUX_PKG_EXTRA_MAKE_ARGS+=' MACH=i386' ;;&
		(x86_64) TERMUX_PKG_EXTRA_MAKE_ARGS+=' MACH=x86_64' ;;&
		(x86_64|i686) TERMUX_PKG_EXTRA_MAKE_ARGS+=' HAVE_SHA=0 HAVE_VAES=0 HAVE_AVX=0 HAVE_AVX2=0 HAVE_SSE42=0' ;;
	esac

	autoheader
	autoconf
}
termux_step_make() {
	## [TERMUX_ON_DEVICE_BUILD] uncomment the check target to run tests for plugins before bumping TERMUX_PKG_VERSION: https://github.com/termux/termux-packages/pull/12113#issuecomment-1257231811
	make EXTRA_CFLAGS="$CFLAGS $CPPFLAGS -std=gnu11" CFLAGS_OPT='$(CFLAGS)' LDFLAGS="$LDFLAGS -Wl,-rpath,${TERMUX_PREFIX}/lib" $TERMUX_PKG_EXTRA_MAKE_ARGS #check
}
termux_step_make_install() {
	install -Dm700 -t "$TERMUX_PREFIX/bin" dd_rescue
	install -Dm700 -t "$TERMUX_PREFIX/lib" libddr_*.so
	install -Dm600 -t "$TERMUX_PREFIX/share/man/man1" dd_rescue.1
	install -Dm600 -t "$TERMUX_PREFIX"/share/doc/$TERMUX_PKG_NAME README.*
}

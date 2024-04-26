TERMUX_PKG_HOMEPAGE=https://github.com/openjdk/mobile
TERMUX_PKG_DESCRIPTION="Java development kit and runtime"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=11.0.23+9
TERMUX_PKG_SRCURL=https://openjdk-sources.osci.io/openjdk11/openjdk-$TERMUX_PKG_VERSION.tar.xz
TERMUX_PKG_SHA256=f51be67721f6cb8d14b0cd75cc9b53634e7d83e808148940d64e67c8b77accfc
TERMUX_PKG_DEPENDS="libiconv, libjpeg-turbo, zlib, libandroid-spawn"
TERMUX_PKG_BUILD_DEPENDS="cups, libandroid-spawn, libandroid-shmem, xorgproto"
# openjdk-11-x is recommended because X11 separation is still very experimental.
TERMUX_PKG_RECOMMENDS="ca-certificates-java, openjdk-11-x, resolv-conf"
TERMUX_PKG_SUGGESTS="cups"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_HAS_DEBUG=false

termux_step_pre_configure() {
	unset JAVA_HOME

	env -i PATH="$PATH" sudo apt update
	env -i PATH="$PATH" sudo apt install openjdk-11-jdk openjdk-11-jre -y
}

termux_step_configure() {
	unset JAVA_HOME

	local jdk_ldflags="-L${TERMUX_PREFIX}/lib -Wl,-rpath=$TERMUX_PREFIX/lib/jvm/java-11-openjdk/lib -Wl,-rpath=${TERMUX_PREFIX}/lib -Wl,--enable-new-dtags"
	bash ./configure \
		--disable-precompiled-headers \
		--disable-warnings-as-errors \
		--enable-option-checking=fatal \
		--openjdk-target=$TERMUX_HOST_PLATFORM \
		--with-cups-include="$TERMUX_PREFIX/include" \
		--with-debug-level=release \
		--with-extra-cflags="$CFLAGS $CPPFLAGS -DLE_STANDALONE -D__ANDROID__=1 -D__TERMUX__=1" \
		--with-extra-cxxflags="$CXXFLAGS $CPPFLAGS -DLE_STANDALONE -D__ANDROID__=1 -D__TERMUX__=1" \
		--with-extra-ldflags="${jdk_ldflags} -Wl,--as-needed -landroid-shmem -landroid-spawn" \
		--with-fontconfig-include="$TERMUX_PREFIX/include" \
		--with-freetype-include="$TERMUX_PREFIX/include/freetype2" \
		--with-freetype-lib="$TERMUX_PREFIX/lib" \
		--with-giflib=system \
		--with-jvm-variants=server \
		--with-libjpeg=system \
		--with-libpng=system \
		--with-toolchain-type=clang \
		--with-x="$TERMUX_PREFIX/include/X11" \
		--with-zlib=system \
		--x-includes="$TERMUX_PREFIX/include/X11" \
		--x-libraries="$TERMUX_PREFIX/lib" \
		AR="$AR" \
		NM="$NM" \
		OBJCOPY="$OBJCOPY" \
		OBJDUMP="$OBJDUMP" \
		STRIP="$STRIP" \
		CXXFILT="llvm-cxxfilt" \
		BUILD_CC="/usr/bin/clang-16" \
		BUILD_CXX="/usr/bin/clang++-16" \
		BUILD_NM="/usr/bin/llvm-nm-16" \
		BUILD_AR="/usr/bin/llvm-ar-16" \
		BUILD_OBJCOPY="/usr/bin/llvm-objcopy-16" \
		BUILD_STRIP="/usr/bin/llvm-strip-16"
}

termux_step_make() {
	cd build/linux-${TERMUX_ARCH/i686/x86}-normal-server-release
	make JOBS=1 images
}

termux_step_make_install() {
	mkdir -p $TERMUX_PREFIX/lib/jvm/java-11-openjdk
	cp -r build/linux-${TERMUX_ARCH/i686/x86}-normal-server-release/images/jdk/* \
		$TERMUX_PREFIX/lib/jvm/java-11-openjdk/
	find $TERMUX_PREFIX/lib/jvm/java-11-openjdk/ -name "*.debuginfo" -delete

	# Dependent projects may need JAVA_HOME.
	mkdir -p $TERMUX_PREFIX/lib/jvm/java-11-openjdk/etc/profile.d
	echo "export JAVA_HOME=$TERMUX_PREFIX/lib/jvm/java-11-openjdk/" > \
		$TERMUX_PREFIX/lib/jvm/java-11-openjdk/etc/profile.d/java.sh
}

termux_step_post_make_install() {
	# Install ca-certs
	mkdir -p $TERMUX_PREFIX/lib/jvm/java-11-openjdk/lib/security/
	ln -sfr $TERMUX_PREFIX/lib/jvm/java-17-openjdk/lib/security/jssecacerts \
		$TERMUX_PREFIX/lib/jvm/java-11-openjdk/lib/security/jssecacerts
	
	cd $TERMUX_PREFIX/lib/jvm/java-11-openjdk/man/man1
	for manpage in *.1; do
		gzip "$manpage"
	done
}

termux_step_create_debscripts() {
	local binaries="$(find $TERMUX_PREFIX/lib/jvm/java-11-openjdk/bin -executable -type f | xargs -I{} basename "{}" | xargs echo)"
	local manpages="$(find $TERMUX_PREFIX/lib/jvm/java-11-openjdk/man/man1 -name "*.1.gz" | xargs -I{} basename "{}" | xargs echo)"
	cat <<-EOF >./postinst
		#!$TERMUX_PREFIX/bin/sh
		if [ "$TERMUX_PACKAGE_FORMAT" = "pacman" ] || [ "\$1" = "configure" ] || [ "\$1" = "abort-upgrade" ]; then
			if [ -x "$TERMUX_PREFIX/bin/update-alternatives" ]; then
				update-alternatives --install $TERMUX_PREFIX/etc/profile.d/java.sh java-profile	$TERMUX_PREFIX/lib/jvm/java-11-openjdk/etc/profile.d/java.sh 11
				for tool in $binaries; do
					update-alternatives --install \
						$TERMUX_PREFIX/bin/\$tool \$tool \
						$TERMUX_PREFIX/lib/jvm/java-11-openjdk/bin/\$tool 11
				done

				for manpage in $manpages; do
					update-alternatives --install \
						$TERMUX_PREFIX/share/man/man1/\$manpage \$manpage \
						$TERMUX_PREFIX/lib/jvm/java-11-openjdk/man/man1/\$manpage 11
				done
			fi
		fi
	EOF

	cat <<-EOF >./prerm
		#!$TERMUX_PREFIX/bin/sh
		if [ "$TERMUX_PACKAGE_FORMAT" = "pacman" ] || [ "\$1" != "upgrade" ]; then
			if [ -x "$TERMUX_PREFIX/bin/update-alternatives" ]; then
				update-alternatives --remove java-profile $TERMUX_PREFIX/etc/profile.d/java.sh
				for tool in $binaries; do
					update-alternatives --remove \$tool $TERMUX_PREFIX/bin/\$tool
				done

				for manpage in $manpages; do
					update-alternatives --remove \$manpage $TERMUX_PREFIX/share/man/man1/\$manpage
				done
			fi
		fi
	EOF
}

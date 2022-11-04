TERMUX_PKG_HOMEPAGE=https://github.com/mongodb/mongo
TERMUX_PKG_DESCRIPTION="A high-performance, open source, schema-free document-oriented database"
TERMUX_PKG_LICENSE="custom"
TERMUX_PKG_LICENSE_FILE="\
build/install/LICENSE-Community.txt
build/install/MPL-2
build/install/THIRD-PARTY-NOTICES"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=6.1.0
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=https://github.com/mongodb/mongo/archive/refs/tags/r$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=f9aa08d43b87694085b06744025702f80acf0efd373b77704a7fd32a7f54eca5
TERMUX_PKG_DEPENDS="libcurl, libstemmer, liblzma, libyaml-cpp, openssl, pcre2, zlib, zstd"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_HOSTBUILD=true
TERMUX_PKG_BLACKLISTED_ARCHES="arm, i686"

termux_step_host_build() {
	env -i PATH="$PATH" sudo apt update
	env -i PATH="$PATH" sudo apt install -yq python3-dev
	mkdir -p $TERMUX_PKG_HOSTBUILD_DIR/venv-dir
	python3 -m venv $TERMUX_PKG_HOSTBUILD_DIR/venv-dir
	(. $TERMUX_PKG_HOSTBUILD_DIR/venv-dir/bin/activate
	python3 -m pip install -r $TERMUX_PKG_SRCDIR/buildscripts/requirements.txt
	python3 -m pip install -r $TERMUX_PKG_SRCDIR/etc/pip/compile-requirements.txt
	python3 -m pip install jsonschema memory_profiler puremagic networkx cxxfilt)
}

termux_step_pre_configure() {
	if [ $TERMUX_ARCH = "aarch64" ]; then
		CFLAGS+=" -march=armv8-a+crc -mtune=generic"
		CXXFLAGS+=" -march=armv8-a+crc -mtune=generic"
	fi

	pushd $TERMUX_PKG_SRCDIR/src/third_party/mozjs
	ln -sfr platform/$TERMUX_ARCH/linux platform/$TERMUX_ARCH/android
	popd
}

termux_step_make() {
	. $TERMUX_PKG_HOSTBUILD_DIR/venv-dir/bin/activate
	python3 ./buildscripts/scons.py install-devcore \
				--allocator=system \
				--libc++=libc++_shared \
				--linker=lld \
				--use-libunwind=off \
				--use-system-pcre2 \
				--use-system-stemmer \
				--use-system-yaml \
				--use-system-zlib \
				--use-system-zstd \
				MONGO_VERSION="$TERMUX_PKG_VERSION" \
				TARGET_OS="android" \
				AR="$(command -v $AR)" \
				CC="$(command -v $CC)" \
				CXX="$(command -v $CXX)" \
				OBJCOPY="$(command -v $OBJCOPY)" \
				STRIP="$(command -v $STRIP)" \
				CFLAGS="$CPPFLAGS $CFLAGS" \
				CXXFLAGS="$CPPFLAGS $CXXFLAGS" \
				LINKFLAGS="$LDFLAGS" \
				CPPPATH="$TERMUX_PREFIX/include" \
				LIBPATH="$TERMUX_PREFIX/lib"
}

termux_step_make_install() {
	$STRIP $TERMUX_PKG_SRCDIR/build/install/bin/mongo{,s,d}
	install -Dm700 -t $TERMUX_PREFIX/bin $TERMUX_PKG_SRCDIR/build/install/bin/mongo{,s,d}
	mkdir -p $TERMUX_PREFIX/var/lib/mongodb/db
	touch $TERMUX_PREFIX/var/lib/mongodb/db/.placeholder
}

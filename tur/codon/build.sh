TERMUX_PKG_HOMEPAGE=https://github.com/exaloop/codon
TERMUX_PKG_DESCRIPTION="A high-performance, zero-overhead, extensible Python compiler using LLVM"
# LICENSE: BSL-1.1 (to Apache-2.0)
# TODO: Review license of non-free packages
TERMUX_PKG_LICENSE="non-free"
TERMUX_PKG_LICENSE_FILE="LICENSE"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION=0.16.3
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=https://github.com/exaloop/codon/archive/refs/tags/v$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=f28b9d8fd5349257aab47154703e9bc744a4884d5975c55776f4b0a72302eb31
TERMUX_PKG_DEPENDS="libc++, libxml2, zlib, zstd"
TERMUX_PKG_BUILD_DEPENDS="libllvm-codon"
TERMUX_PKG_NO_STATICSPLIT=true
TERMUX_PKG_HOSTBUILD=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_TAG_TYPE="latest-release-tag"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DLLVM_DIR=$TERMUX_PREFIX/opt/codon/lib/cmake/llvm
-DCMAKE_INSTALL_PREFIX=$TERMUX_PREFIX/opt/codon
"

# On ARM and i686, codon crashes:
# JIT session error: Unsupported target machine architecture in ELF object codon-jitted-objectbuffer
# Failure value returned from cantFail wrapped call
TERMUX_PKG_BLACKLISTED_ARCHES="arm, i686"

termux_step_host_build() {
	env -i PATH="$PATH" sudo apt update
	env -i PATH="$PATH" sudo apt install -y libzstd-dev

	termux_setup_cmake
	cmake "$TERMUX_PKG_SRCDIR"
	make -j $TERMUX_PKG_MAKE_PROCESSES peg2cpp
}

termux_step_pre_configure() {
	export PATH="$TERMUX_PKG_HOSTBUILD_DIR:$PATH"

	_RPATH_FLAG="-Wl,-rpath=$TERMUX_PREFIX/lib"
	_RPATH_FLAG_ADD="-Wl,-rpath='\$ORIGIN' -Wl,-rpath='\$ORIGIN/../lib/codon' -Wl,-rpath=$TERMUX_PREFIX/lib"
	LDFLAGS="${LDFLAGS/$_RPATH_FLAG/$_RPATH_FLAG_ADD} -Wl,--undefined-version"
	echo $LDFLAGS
}

termux_step_post_make_install() {
	# Create start script
	cat << EOF > $TERMUX_PREFIX/bin/codon
#!$TERMUX_PREFIX/bin/env sh

exec env PATH="$TERMUX_PREFIX/opt/codon/bin:\$PATH" $TERMUX_PREFIX/opt/codon/bin/codon "\$@"

EOF
	chmod +x $TERMUX_PREFIX/bin/codon
}

termux_step_post_massage() {
	# Remove libfmt.a
	rm -rf lib
}

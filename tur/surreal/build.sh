TERMUX_PKG_HOMEPAGE=https://github.com/surrealdb/surrealdb
TERMUX_PKG_DESCRIPTION="A scalable, distributed, collaborative, document-graph database, for the realtime web"
TERMUX_PKG_LICENSE="non-free"
TERMUX_PKG_LICENSE_FILE="LICENSE"
TERMUX_PKG_MAINTAINER="@SunPodder"
TERMUX_PKG_VERSION="1.2.1"
TERMUX_PKG_SRCURL="https://github.com/surrealdb/surrealdb/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=e3d1fd737ed621edda71e8495bd540678c19d8847d115d5a1d1e823bd9f83bc5
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_BUILD_DEPENDS="openssl, zlib"
TERMUX_PKG_BLACKLISTED_ARCHES="arm, i686"

termux_step_configure() {
	env -i PATH="$PATH" sudo apt update
	env -i PATH="$PATH" sudo apt install protobuf-compiler -y

    termux_setup_rust
    export CARGO_HOME="${HOME}/.cargo"
    cargo fetch --target $CARGO_TARGET_NAME

    rm -rf $CARGO_HOME/registry/src/index.crates.io-*/librocksdb-sys-0.11.0*/
    rm -rf $CARGO_HOME/registry/src/index.crates.io-*/jemalloc-sys*/
    cargo fetch --target $CARGO_TARGET_NAME

    sed -e "s|@TERMUX_PREFIX@|$TERMUX_PREFIX|" \
        $TERMUX_PKG_BUILDER_DIR/librocksdb-sys.diff \
	    | patch --silent -p1 \
            -d $CARGO_HOME/registry/src/index.crates.io-*/librocksdb-sys-0.11.0*/rocksdb

    cat $TERMUX_PKG_BUILDER_DIR/jemalloc-sys.diff \
        | patch --silent -p1 \
            -d $CARGO_HOME/registry/src/index.crates.io-*/jemalloc-sys-*/
}

termux_step_make() {
    export CXXFLAGS+=" -lz"
	cargo build --jobs $TERMUX_MAKE_PROCESSES --target $CARGO_TARGET_NAME --release
}

termux_step_make_install() {
	install -Dm755 -t $TERMUX_PREFIX/bin target/${CARGO_TARGET_NAME}/release/surreal
}


TERMUX_PKG_HOMEPAGE=https://github.com/surrealdb/surrealdb
TERMUX_PKG_DESCRIPTION="A scalable, distributed, collaborative, document-graph database, for the realtime web"
TERMUX_PKG_LICENSE="non-free"
TERMUX_PKG_LICENSE_FILE="LICENSE"
TERMUX_PKG_MAINTAINER="@SunPodder"
TERMUX_PKG_VERSION="1.0.0-beta.9+20230402"
TERMUX_PKG_SRCURL="https://github.com/surrealdb/surrealdb/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=d7eff95256663a60c214b59ee0a76fe5f982f22e77c66582cdfdc347c51d181a
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_BUILD_DEPENDS="openssl, zlib"
TERMUX_PKG_BLACKLISTED_ARCHES="i686"

termux_step_configure() {
	env -i PATH="$PATH" sudo apt update
	env -i PATH="$PATH" sudo apt install protobuf-compiler -y

    termux_setup_rust
    export CARGO_HOME="${HOME}/.cargo"

    cargo fetch --target $CARGO_TARGET_NAME
    sed -e "s|@TERMUX_PREFIX@|$TERMUX_PREFIX|" \
        $TERMUX_PKG_BUILDER_DIR/librocksdb-sys-0.10.0.diff \
	    | patch --silent -p1 \
            -d $CARGO_HOME/registry/src/github.com-*/librocksdb-sys-0.10.0*/rocksdb
}

termux_step_make() {
    export CXXFLAGS+=" -lz"
	cargo build --jobs $TERMUX_MAKE_PROCESSES --target $CARGO_TARGET_NAME --release
}

termux_step_make_install() {
	install -Dm755 -t $TERMUX_PREFIX/bin target/${CARGO_TARGET_NAME}/release/surreal
}


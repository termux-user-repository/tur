TERMUX_PKG_HOMEPAGE=https://github.com/surrealdb/surrealdb
TERMUX_PKG_DESCRIPTION="A scalable, distributed, collaborative, document-graph database, for the realtime web"
# LICENSE: Business Source License 1.1 (BSL-1.1)
TERMUX_PKG_LICENSE="non-free"
TERMUX_PKG_LICENSE_FILE="LICENSE"
TERMUX_PKG_MAINTAINER="@SunPodder"
TERMUX_PKG_VERSION="2.2.1"
TERMUX_PKG_SRCURL="https://github.com/surrealdb/surrealdb/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=8cdc3f28909b25d9d0107ab1de53f55a09ef962cae992a4a47d1b0d5566d43bb
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_DEPENDS="openssl, zlib"
TERMUX_PKG_BLACKLISTED_ARCHES="arm, i686"

termux_step_configure() {
	termux_setup_protobuf
	termux_setup_rust

	: "${CARGO_HOME:=$HOME/.cargo}"
	export CARGO_HOME

	cargo vendor
	find ./vendor \
		-mindepth 1 -maxdepth 1 -type d \
		! -wholename ./vendor/librocksdb-sys \
		-exec rm -rf '{}' \;

	sed -e "s|@TERMUX_PREFIX@|$TERMUX_PREFIX|" \
		$TERMUX_PKG_BUILDER_DIR/librocksdb-sys.diff \
		| patch --silent -p1 -d ./vendor/librocksdb-sys/

	echo "" >> Cargo.toml
	echo "[patch.crates-io]" >> Cargo.toml
	echo "librocksdb-sys = { path = \"./vendor/librocksdb-sys\" }" >> Cargo.toml
}

termux_step_make() {
	export CXXFLAGS+=" -lz"
	export RUSTFLAGS="--cfg surrealdb_unstable"
	cargo build --jobs $TERMUX_PKG_MAKE_PROCESSES --target $CARGO_TARGET_NAME --release
}

termux_step_make_install() {
	install -Dm755 -t $TERMUX_PREFIX/bin target/${CARGO_TARGET_NAME}/release/surreal
}

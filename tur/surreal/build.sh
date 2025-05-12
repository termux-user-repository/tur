TERMUX_PKG_HOMEPAGE=https://github.com/surrealdb/surrealdb
TERMUX_PKG_DESCRIPTION="A scalable, distributed, collaborative, document-graph database, for the realtime web"
# LICENSE: Business Source License 1.1 (BSL-1.1)
TERMUX_PKG_LICENSE="non-free"
TERMUX_PKG_LICENSE_FILE="LICENSE"
TERMUX_PKG_MAINTAINER="@SunPodder"
TERMUX_PKG_VERSION="2.3.2"
TERMUX_PKG_SRCURL="https://github.com/surrealdb/surrealdb/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=b39eb0c789fb59f87b7cdc44271eb79d6ee53e5467ef8a45f60a35f3438e7777
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_DEPENDS="openssl, zlib"
TERMUX_PKG_EXCLUDED_ARCHES="arm, i686"

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

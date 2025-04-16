TERMUX_PKG_HOMEPAGE="https://github.com/OptiVorbis/OptiVorbis"
TERMUX_PKG_DESCRIPTION="Vorbis optimizer that reconstruct ogg files to a smaller size, without losing any audio quality"
TERMUX_PKG_LICENSE="AGPL-V3"
TERMUX_PKG_MAINTAINER="@flosnvjx"
TERMUX_PKG_VERSION="0.3.0"
TERMUX_PKG_SRCURL="https://github.com/OptiVorbis/OptiVorbis/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=f1069b35fa24c9b73abb9a28859b84ad0accf968b8892b7a7825decc6c316cd3
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	rm -rf .cargo
	termux_setup_rust
	rustup toolchain install nightly
	rustup component add rust-src --toolchain nightly
	echo "nightly" > $TERMUX_PKG_SRCDIR/rust-toolchain
}

termux_step_make() {
	OPTIVORBIS_VERSION=$TERMUX_PKG_VERSION OPTIVORBIS_BUILD_DATE="$(date -u +%Y-%m-%d)" cargo build --jobs $TERMUX_PKG_MAKE_PROCESSES --target $CARGO_TARGET_NAME --release --locked \
		-Z build-std=panic_abort,core,std,alloc,proc_macro \
		-Z build-std-features=panic_immediate_abort
}

termux_step_make_install() {
	install -vDm755 -t $TERMUX_PREFIX/bin target/${CARGO_TARGET_NAME}/release/optivorbis
	install -vDm644 -t $TERMUX_PREFIX/share/doc/$TERMUX_PKG_NAME README* CHANGELOG*
}

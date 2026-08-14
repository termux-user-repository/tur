TERMUX_PKG_HOMEPAGE=https://github.com/Duro02/grok-build-termux
TERMUX_PKG_DESCRIPTION="Grok Build TUI for Termux (unofficial Android port of xAI Grok Build)"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@Duro02"
TERMUX_PKG_VERSION="1.0.4"
TERMUX_PKG_SRCURL=https://github.com/Duro02/grok-build-termux/archive/refs/tags/termux-v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=a13e589bb426e6631839a3ffbec220c5a3741b8e84ec23f96a1efa27d5d626ec
TERMUX_PKG_DEPENDS="libc++, ripgrep, termux-api"
TERMUX_PKG_BUILD_DEPENDS="protobuf"
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_make() {
	termux_setup_rust

	# The repo's .cargo/config.toml wires a device-side linker wrapper for
	# aarch64; the packaging environment provides its own per-arch clang.
	sed -i '/termux-android-linker.sh/d' .cargo/config.toml

	# Termux provides only the shared C++ runtime. Rust's Android target asks
	# for libc++_static by default, so translate the request before invoking
	# the packaging linker (same approach as scripts/termux-android-linker.sh
	# in the source repository).
	linker_wrapper="$TERMUX_PKG_TMPDIR/rust-linker"
	cat > "$linker_wrapper" <<-EOF
	#!/bin/sh
	args=""
	for a in "\$@"; do
		if [ "\$a" = "-lc++_static" ]; then args="\$args -lc++_shared"; else args="\$args \$a"; fi
	done
	exec "\$GROK_LINKER" \$args
	EOF
	chmod 755 "$linker_wrapper"

	linker_env="CARGO_TARGET_$(echo "$CARGO_TARGET_NAME" | tr 'a-z' 'A-Z' | tr '-' '_')_LINKER"
	export GROK_LINKER="${!linker_env:-$TERMUX_STANDALONE_TOOLCHAIN/bin/${TERMUX_HOST_PLATFORM}-clang}"
	export "$linker_env=$linker_wrapper"

	export PROTOC="$TERMUX_PREFIX/bin/protoc"
	cargo build --jobs "$TERMUX_PKG_MAKE_PROCESSES" \
		--target "$CARGO_TARGET_NAME" \
		--release \
		-p xai-grok-pager-bin \
		--no-default-features
}

termux_step_make_install() {
	install -Dm700 "target/${CARGO_TARGET_NAME}/release/xai-grok-pager" \
		"$TERMUX_PREFIX/bin/grok"
	install -Dm600 -t "$TERMUX_PREFIX/share/doc/grok" TERMUX.md
}

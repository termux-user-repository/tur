TERMUX_SUBPKG_DESCRIPTION="Rust std for target armv7-linux-androideabi (nightly version)"
TERMUX_SUBPKG_DEPEND_ON_PARENT=false
TERMUX_SUBPKG_PLATFORM_INDEPENDENT=true
TERMUX_SUBPKG_INCLUDE="
opt/rust-nightly/lib/rustlib/armv7-linux-androideabi/lib/*.rlib
opt/rust-nightly/lib/rustlib/armv7-linux-androideabi/lib/libstd-*.so
"

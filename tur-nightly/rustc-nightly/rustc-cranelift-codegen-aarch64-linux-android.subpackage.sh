TERMUX_SUBPKG_DESCRIPTION="Rust cranelift codegen for target aarch64-linux-android (nightly version)"
TERMUX_SUBPKG_INCLUDE="
opt/rust-nightly/lib/rustlib/aarch64-linux-android/codegen-backends/librustc_codegen_cranelift*.so
"
TERMUX_SUBPKG_EXCLUDED_ARCHES="arm, i686, x86_64"

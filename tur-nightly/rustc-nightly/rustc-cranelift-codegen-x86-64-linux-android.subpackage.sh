TERMUX_SUBPKG_DESCRIPTION="Rust cranelift codegen for target x86_64-linux-android (nightly version)"
TERMUX_SUBPKG_INCLUDE="
opt/rust-nightly/lib/rustlib/x86_64-linux-android/codegen-backends/librustc_codegen_cranelift*.so
"
TERMUX_SUBPKG_EXCLUDED_ARCHES="aarch64, arm, i686"

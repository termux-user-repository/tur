TERMUX_SUBPKG_DESCRIPTION="Compiler runtime libraries for clang"
TERMUX_SUBPKG_INCLUDE="
$_INSTALL_PREFIX_R/lib/clang/*/bin/asan_device_setup
$_INSTALL_PREFIX_R/lib/clang/*/bin/hwasan_symbolize
$_INSTALL_PREFIX_R/lib/clang/*/include/fuzzer/FuzzedDataProvider.h
$_INSTALL_PREFIX_R/lib/clang/*/include/profile/InstrProfData.inc
$_INSTALL_PREFIX_R/lib/clang/*/include/sanitizer/
$_INSTALL_PREFIX_R/lib/clang/*/include/xray/
$_INSTALL_PREFIX_R/lib/clang/*/lib/linux/
$_INSTALL_PREFIX_R/lib/clang/*/share/asan_ignorelist.txt
$_INSTALL_PREFIX_R/lib/clang/*/share/cfi_ignorelist.txt
$_INSTALL_PREFIX_R/lib/clang/*/share/hwasan_ignorelist.txt
"

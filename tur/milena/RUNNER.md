# Milena TUR package contract

`tur/milena/build.sh` packages the **canonical** `46Neon/Milena` release tarball only. It does not add a runtime, fork, parser, generated source, or hardware emulation.

## Release and source guards

For every update, `TERMUX_PKG_VERSION`, the `v<version>` tag in `TERMUX_PKG_SRCURL`, and `TERMUX_PKG_SHA256` must be updated together. The checksum is recalculated from that exact GitHub release archive. The recipe rejects a missing Makefile/license/README, a non-`milena` Make target, a mismatched `MILENA_VERSION`, missing canonical lexer/parser/AST/semantic/runtime/table sources, and failures of the upstream source-manifest and experimental-isolation checks.

## Build, test, smoke, and payload

The TUR build phase runs `make all` with TUR's `make` and Termux `clang`, `-std=c17`, and `-lm`. It verifies Clang, Android/Bionic (`__ANDROID__`), and C17 before compilation. These are build-toolchain properties, not package runtime dependencies; only Python is declared build-only for the upstream guard scripts.

`termux_step_make_test` is intentionally separate from `termux_step_make`. TUR/build-package versions or workflows may not invoke that hook automatically, so a successful package build is **not** a test result. When a test phase is requested, run:

```sh
./build-package.sh -I -C milena   # TUR package build
# in the extracted source/build test phase:
make TERMUX=1 CC=clang CFLAGS='-std=c17 -Iinclude' LDFLAGS='-lm' test
./milena --version                # functional smoke, separate from compilation
```

The install step contributes exactly:

- `${TERMUX_PREFIX}/bin/milena`
- `${TERMUX_PREFIX}/share/doc/milena/README.md`

Tests, source files, scripts, Makefiles, compilers, and other generated artifacts must not be copied into the package payload. The installed binary must be tested with `milena --version` and, where a real device is available, a small language program; do not call a build result a functional smoke result.

## Real-device matrix and evidence

The package is cross-built for the architectures supported by the active TUR workflow. The Android/aarch64 lifecycle contract below requires a **real** Termux device/runner, not QEMU, an emulator, a container, or host Linux. A future runner should record architecture/ABI, compiler identity, and exit status for each command:

```sh
uname -o -m
getprop ro.product.cpu.abi
command -v pkg make clang
clang --version
pkg update
pkg install tur-repo
pkg install milena
milena --version
pkg upgrade
pkg remove milena
```

Expected architecture evidence is Android/Bionic and `aarch64`; the commands must report observed values, never inferred values. Until a labeled real runner executes this lifecycle, its status is **pending**. This document does not claim that TUR publishes `milena`, that `tur-repo` is configured, or that any architecture has passed.

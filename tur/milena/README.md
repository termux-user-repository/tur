# Milena in TUR

This directory is a TUR recipe contract, not a second Milena implementation. The package is built only from the stable upstream release tarball `46Neon/Milena` v0.2.0. PR26 is still open, so this recipe intentionally does not consume its branch or invent a newer version.

## What CI proves

The official TUR `Packages-TUR` workflow builds the package for `aarch64`, `arm`, `i686`, and `x86_64` using the matrix already maintained by TUR. The recipe verifies the release checksum, source layout and version identity, Android/Bionic C17 compilation, canonical source-manifest/isolation guards, staged payload, and (when available in the builder) ELF headers and `DT_NEEDED`.

A successful cross-build is not a device installation test. Artifacts are uploaded by TUR only when the upstream repository runs the upload job on `master`; a fork/PR cannot publish packages or trigger `dists`.

## Installation lifecycle (physical Termux device required)

After TUR maintainers publish and `tur-repo` is available on the device, run:

```sh
pkg update
pkg install tur-repo
pkg install milena
milena --version
milena --help
milena --self-check
# execute a small canonical Milena program
pkg upgrade
pkg remove milena
```

Record the observed ABI (`getprop ro.product.cpu.abi`), architecture (`uname -m`), package version, and command output. Do not report this lifecycle as passed from GitHub Actions, QEMU, an emulator, a container, or a host build.

## Device runner status

No Android/Bionic physical runner credentials or label are available to this contributor. Therefore no device result is claimed and any future device job must fail closed unless its runner has all of `ANDROID_SERIAL`, `adb`, a connected physical Termux device, and an explicit maintainer-provided label. The maintainer connecting it should:

1. provision a self-hosted runner in the TUR repository with a dedicated label (for example `termux-milena-device-aarch64`),
2. install Termux/`adb`, authorize the device, and expose `ANDROID_SERIAL`,
3. restrict the job to that label and require an explicit `workflow_dispatch` input,
4. run the lifecycle above and upload raw logs plus ABI/version evidence, and
5. remove or rotate the runner credentials after the test.

Until those permissions and a physical device exist, the status is **pending**, not passed.

## Release update rule

When a new stable Milena release exists, update `TERMUX_PKG_VERSION`, the `v<version>` source tag, and `TERMUX_PKG_SHA256` together, then rerun all four official TUR builds. Do not point the recipe at PR branches, untagged commits, or a guessed checksum.

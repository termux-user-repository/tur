# Milena TUR runner contract

This is a validation contract, not a claim that a device or runner is currently
available. It applies only to a real Android/Bionic `aarch64` Termux host
registered with the labels `self-hosted`, `termux`, `aarch64`, and `milena`.
No emulator, QEMU, container, or host-Linux substitution satisfies this
contract.

## Required device checks

On the device, before running validation:

```sh
uname -o -m
getprop ro.product.cpu.abi
command -v pkg make clang
clang --version
```

The observed values must identify Android/Bionic and `aarch64`; the command
must not infer or manufacture those properties. The build job must use the
TUR-provided toolchain and the package recipe's checks for `make`, Clang, C17,
and Android/Bionic compiler predefines.

## Package lifecycle smoke test

After a TUR repository is configured on the real device, the operator may run
these commands as a non-root Termux user:

```sh
pkg update
pkg install tur-repo
pkg install milena
milena --version
pkg upgrade
pkg remove milena
```

`tur-repo` and `milena` are expected package names in this contract. Their
availability is a prerequisite to be verified by the operator; this document
does not publish a repository, create a runner, or claim that either package
is currently available. `pkg upgrade` is the upgrade-path check, and
`pkg remove milena` is the removal-path check. Do not run these commands in a
package-build CI job or invent their results.

## CI status and evidence

A future self-hosted job should record the device ABI, compiler identity, and
exit status of each lifecycle command without collecting unrelated personal
data. Until a real labeled runner executes it, the Android/aarch64 lifecycle
status remains **pending**, and no TUR or Milena documentation should describe
it as validated.

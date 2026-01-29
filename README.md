# Termux User Repository (TUR)

TUR is a repository for Termux that offers precompiled packages.

## Subscribe to TUR
Add TUR in Termux. 
```
pkg install tur-repo
```
Once `tur-repo` successfully installed. TUR packages can be install with pkg or apt in same ways. 

NOTE: TUR's apt repository consists of many components. `tur`, `tur-on-device` and `tur-continuous` are available by default. If you want to subscribe to other components in TUR you can add them manually.

TUR also hosts a PyPI index and contains some prebuilt Python packages.
```
python -m pip install some_packages --extra-index-url https://termux-user-repository.github.io/pypi/
```

You can add this index to your pip config for convenience by adding the following lines to your pip config (`~/.config/pip/pip.conf`):
```
[install]
extra-index-url = https://termux-user-repository.github.io/pypi/
```

## Request for all TUR users

Please open issues about TUR packages in this repository.

## Contribution

### Set up build environment

#### Method 1 (Conventional)
TUR uses same building scripts that Termux does. So the building mechanism is same.
* Clone this repository.
* Change directory and execute `./setup-environment.sh` It will fetch Termux package building scripts ([`termux/termux-packages`](https://github.com/termux/termux-packages)). 
* Set up build environment following [this official Termux guide](https://github.com/termux/termux-packages/wiki/Build-environment). 

#### Method 2 (Dev Container)
* Clone this repository
* Create a Dev Container:
    * Visual Studio Code (local, docker required): `Ctrl + Shift + P` &rarr; `>Dev Containers: Open Folder in Container...` &rarr; pick this repository
    * GitHub Codespaces (online): `<> Code` button on this repository GitHub website &rarr; `Codespaces` &rarr; `+`

### Create and build a new package
* Create build.sh file under **`tur/<your-package-name>`** directory (_not in `packages/<your-package-name>`_). For more details, see the official wiki "[Creating new package](https://github.com/termux/termux-packages/wiki/Creating-new-package)". 
* Build the package with 
    ```
    TERMUX_INSTALL_DEPS=true ./build-package.sh -a <arch> <package-name>
    ```
  * `<arch>` accepts aarch64, arm, i686, x86_64. 
  * `TERMUX_NO_CLEAN=true` should be needed when building on an Android device. 
  * For more details, see the official wiki "[How to build package](https://github.com/termux/termux-packages/wiki/Building-packages)" and "[Build environment](https://github.com/termux/termux-packages/wiki/Build-environment)". 
* Patch the source if needed. One way to do so is:
  * After running `./build-package.sh` in the previous step, enter into `~/.termux-build/<package-name>/src` (using VS Code `File` &rarr; `Open Folder...` or `cd` in terminal)
  * *If git is not set up in the directory*, run
    ```
    git init .
    git commit -a -m "first commit"
    ```
  * modify files needed to be patched and then run 
    ```
    git diff <path-to-modified-file> > <path-to-tur-repo>/tur/<package-name>/<any-name>.patch
    ```
  * re-run `./build-package.sh` in the previous step. 

## TUR as a solution

* Less popular packages can be added.
* Many Python/Node/Ruby packages needs compilation in device. TUR could make installation easy via distributing .deb file.
* Instead of hosting their own apt repository, one could add their package in TUR. 
* One place for a lot of packages which could not be part of official Termux repository for some reason.
* Old versions of packages available in TUR. 

## Suggestions
Suggestions and ideas are always welcome.

Please let us know your suggestions by starting a discussion/issue.

## Components and other git repos
The components in TUR are listed below.

`tur`: The main component. It contains almost all the packages.

`tur-on-device`: This component contains some packages that cannot be cross-compiled. It uses [Termux-Docker](https://github.com/termux/termux-docker) to simulate a Termux-like environment. It runs under a self-hosted ARM environment and GitHub Actions provided x86 environment. Not every package is able to compile under it.

`tur-continuous`: This component contains some packages that costs lots of time to compile.

`tur-hacking`: This component contains some hacking tools.

`tur-multilib`: This component contains some packages that provide a multilib environment.

Some other components may be added to TUR. If you're interested in it, please see [TODO.md](TODO.md) for more information.

TUR also maintains some other git repositories. These git repositories are listed below.

`electron-tur-builder`: It contains some scripts to build specific version of electron and release the pre-built binaries to GitHub Release. This repository provides an APT component called `tur-electron`.

`pypi-wheel-builder`: It contains some scripts to build and publish wheels to a custom PyPI index.

`pypi`: It hosts the pages of a PyPI index for Termux/Android. 

`dists`: It contains some scripts to publish the APT repo, host the GitHub Pages, and holds .deb files in its releases.

`termux-docker`: It is forked from [termux/termux-docker](https://github.com/termux/termux-docker). The original one contains some binaries and libraries which is targeting API 28, and the fork contains them which is targeting API 24.

`ndk-toolchain-gcc-9/10/11/12`: These repos contain some build scripts to build a NDK toolchain with GCC rather than LLVM.

`tur-on-device` **Archived**: It has been merged into TUR.

## Stargazers over time
[![Stargazers over time](https://starchart.cc/termux-user-repository/tur.svg?variant=adaptive)](https://starchart.cc/termux-user-repository/tur)

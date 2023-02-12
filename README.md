# Termux User Repository (TUR)

Sounds like Archlinux User repository aka AUR ? TUR functioning mechanism is bit different. Instead of building packages in device that too in android is quite hectic work for user. 
So TUR saves resources and time since user could install pre-compiled package. 

## Subscribe TUR
Add TUR in Termux. 
```
pkg install tur-repo
```
Once `tur-repo` successfully installed. TUR packages can be install with pkg or apt in same ways. 

NOTE: TUR's apt repository is consist of many components. `tur`, `tur-on-device` and `tur-continuous` are avaiable by default. If you want to subscribe other components in TUR, please add them manually.

## Request
*Request to all TUR users.*

Please don't Discuss/Open issues about any of TUR packages in Termux Offical forum. TUR packages are not Termux official packages so any discussion just waste time of Termux maintainters. Users are free to discuss/open isuess here. 

## Contribution

### Add new package. 
TUR uses same building scripts what Termux does.So all building mechanism is same.
* Clone this repository.
* Change directory and Execute `./setup-environment.sh` It will fetch Termux package building scripts. 
* Create build.sh file under **tur** directory (_not in packages_). 
Go through the official termux [wiki](https://github.com/termux/termux-packages/wiki). 


## TUR as a solution
TUR solves following issues of termux user: 

* Less popular packages could be added too.
* Many python/node/ruby packages needs compilation in device. TUR could make installation easy via distributing deb file.
* Instead of hosting own apt repository, One could add their package in TUR. 
* One place for all packages which could not be part of official termux repo for some reason.
* Old versions of packages available in TUR. 



## Suggestions
Suggestions/ideas are always welcome.

Let's make TUR a single/trusted place for all unofficial debfile which supposed to be run in Termux. 
In order to achieve it we need your precious suggestions. Please let us know your suggestions through starting a discussion/issue.

## Components and other git repos
The components in TUR are listed below.

`tur`: The main component. It contains almost all the packages.

`tur-on-device`: This component contains some packages that cannot be cross-compiling. It uses [Termux-Docker](https://github.com/termux/termux-docker) to simulate a Termux-like environment. It runs under a self-hosted arm environment and Github-Action-provided x86 environment. Not every package is able to compile under it.

`tur-continuous`: This component contains some packages that costs lots of time to compile, e.g. chromium-based applications.

`tur-hacking`: This component contains some hacking tools.

`tur-multilib` **WIP**: This component contains some packages that provide a multilib environment.

Some other components may be added to TUR. If you're interested in it, please see [TODO.md](TODO.md) for more information.

TUR also maintains some other git repos. These git repos are listed below.

`electron-tur-builder`: It contains some scripts to build specific version of electron and release the pre-built binaries to GitHub Release. This repository provides an APT component called `tur-electron`.

`pypi-index-tur`: It contains some scripts to build and publish wheels to a custom pypi index.

`pypi`: It hosts the pages of a pypi index for Termux/Android. 

`dists`: It contains some scripts to publish APT repo, hosts the GitHub Pages, and holds deb files in its Releases.

`termux-docker`: It is forked from [termux/termux-docker](https://github.com/termux/termux-docker). The original one contains some binaries and libraries which is targeting API 28, and the fork contains them which is targeting API 24.

`ndk-toolchain-gcc-9/10/11/12`: These repos contain some build scripts to build a NDK toolchain with GCC rather than LLVM.

`tur-on-device` **Archived**: It has been merged into TUR.

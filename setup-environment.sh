#!/bin/bash
# setup-environment.sh - script to setup a building environment for termux-user-repository

set -e -u -o pipefail

# Enter the working directory
basedir=$(realpath $(dirname $0))
cd $basedir

# Checkout the master branch of termux/termux-packages
if [ -d "./termux-packages" ] && [ -d "./termux-packages/.git" ]; then
	echo "Pulling termux-packages..."
	pushd ./termux-packages
	git reset --hard origin/master
	git pull --rebase
	popd
else
	rm -rf ./termux-packages
	git clone https://github.com/termux/termux-packages.git
fi

# Remove old stuffs
rm -rf {ndk-patches,packages,x11-packages,root-packages,scripts,build-all.sh,build-package.sh,clean.sh}

# Move build environment scripts to this folder
mv ./termux-packages/{ndk-patches,packages,x11-packages,root-packages,scripts,build-all.sh,build-package.sh,clean.sh} ./

# Apply script patches.
shopt -s nullglob
_patch=
for _patch in ./common-files/building-system-patches/*.patch; do
	echo "Applying patch: $_patch"
	patch --silent -p1 < $_patch
done
unset _patch
shopt -u nullglob

# Remove override packages
cat ./common-files/override-packages.txt | xargs rm -rfv --

# Remove files
rm -f build-package.sh.orig

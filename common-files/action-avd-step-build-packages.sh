#!/bin/bash
packages=""
for repo_path in $(jq --raw-output 'keys | .[]' repo.json); do
	repo=$(jq --raw-output '.["'${repo_path}'"].name' repo.json)
	if [ -f ./built_${repo}_packages.txt ]; then
		echo "./built_${repo}_packages.txt: $(cat ./built_${repo}_packages.txt)"
		packages="$packages $(cat ./built_${repo}_packages.txt)"
	fi
done
if [ ! -z "$packages" ]; then
	env TERMUX_ARCH=$TERMUX_ARCH PACKAGE_TO_BUILD="$packages" ./adb-build-wrapper.sh
fi

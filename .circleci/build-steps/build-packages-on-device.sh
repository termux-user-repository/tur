#!/usr/bin/env bash

: ${ARCH:=aarch64}
export ARCH

# Install deps
./common-files/build-termux-docker.sh login ./scripts/setup-termux.sh

# Build packages
declare -a packages
for repo_path in $(jq --raw-output 'keys | .[]' repo.json); do
    repo=$(jq --raw-output '.["'${repo_path}'"].name' repo.json)
    if [ -f ./built_${repo}_packages.txt ]; then
        packages="$packages $(cat ./built_${repo}_packages.txt)"
    fi
done
sudo chown -R 1000:1000 $(pwd)
if [ ! -z "$packages" ]; then
    ./common-files/build-termux-docker.sh login ./build-package.sh -I $packages
fi

# Generate build artifacts
sudo chown -R $(id -u):$(id -u) $(pwd)
for repo in $(jq --raw-output '.[].name' repo.json); do
    # Put package lists into directory with *.deb files so they will be transferred to
    # upload job.
    test -f ./built_${repo}_packages.txt && mv ./built_${repo}_packages.txt ./debs/
    test -f ./built_${repo}_subpackages.txt && cat ./built_${repo}_subpackages.txt >> ./debs/built_${repo}_packages.txt \
        && rm ./built_${repo}_subpackages.txt
    test -f ./deleted_${repo}_packages.txt && mv ./deleted_${repo}_packages.txt ./debs/
    # Move only debs from built_packages into debs/ folder before
    # creating an archive.
    while read -r pkg; do
        # Match both $pkg.deb and $pkg-static.deb.
        find output \( -name "$pkg_*.deb" -o -name "$pkg-static_*.deb" \) -type f -print0 | xargs -0r mv -t debs/
    done < <(cat ./debs/built_${repo}_packages.txt)
done
# Files containing certain symbols (e.g. ":") will cause failure in actions/upload-artifact.
# Archiving *.deb files in a tarball to avoid issues with uploading.
tar cf artifacts/debs-${ARCH}-${CIRCLE_SHA1}.tar debs

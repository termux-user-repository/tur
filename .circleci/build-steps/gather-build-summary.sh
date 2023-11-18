#!/usr/bin/env bash

: ${MAIN_BRANCH_NAME:=master}

mkdir -p ./artifacts ./debs
touch ./debs/.placeholder
CHANGED_FILES=$(git diff-tree --no-commit-id --name-only -r "${MAIN_BRANCH_NAME}" "HEAD")
for repo_path in $(jq --raw-output 'keys | .[]' repo.json); do
    repo=$(jq --raw-output '.["'${repo_path}'"].name' repo.json)
    # Parse changed files and identify new packages and deleted packages.
    # Create lists of those packages that will be passed to upload job for
    # further processing.
    while read -r file; do
        if ! [[ $file == ${repo_path}/* ]]; then
            # This file does not belong to a package, so ignore it
            continue
        fi
        if [[ $file =~ ^${repo_path}/([.a-z0-9+-]*)/([.a-z0-9+-]*).subpackage.sh$ ]]; then
            # A subpackage was modified, check if it was deleted or just updated
            pkg=${BASH_REMATCH[1]}
            subpkg=${BASH_REMATCH[2]}
            if [ ! -f "${repo_path}/${pkg}/${subpkg}.subpackage.sh" ]; then
                echo "$subpkg" >> ./deleted_${repo}_packages.txt
            fi
        elif [[ $file =~ ^${repo_path}/([.a-z0-9+-]*)/.*$ ]]; then
            # package, check if it was deleted or updated
            pkg=${BASH_REMATCH[1]}
            if [ -d "${repo_path}/${pkg}" ]; then
                echo "$pkg" >> ./built_${repo}_packages.txt
                # If there are subpackages we want to create a list of those
                # as well
                for file in $(find "${repo_path}/${pkg}/" -maxdepth 1 -type f -name \*.subpackage.sh | sort); do
                echo "$(basename "${file%%.subpackage.sh}")" >> ./built_${repo}_subpackages.txt
                done
            else
                echo "$pkg" >> ./deleted_${repo}_packages
            fi
        fi
    done<<<${CHANGED_FILES}
done
for repo in $(jq --raw-output '.[].name' repo.json); do
    # Fix so that lists do not contain duplicates
    if [ -f ./built_${repo}_packages.txt ]; then
        uniq ./built_${repo}_packages.txt > ./built_${repo}_packages.txt.tmp
        mv ./built_${repo}_packages.txt.tmp ./built_${repo}_packages.txt
    fi
    if [ -f ./built_${repo}_subpackages.txt ]; then
        uniq ./built_${repo}_subpackages.txt > ./built_${repo}_subpackages.txt.tmp
        mv ./built_${repo}_subpackages.txt.tmp ./built_${repo}_subpackages.txt
    fi
    if [ -f ./deleted_${repo}_packages.txt ]; then
        uniq ./deleted_${repo}_packages.txt > ./deleted_${repo}_packages.txt.tmp
        mv ./deleted_${repo}_packages.txt.tmp ./deleted_${repo}_packages.txt
    fi
done

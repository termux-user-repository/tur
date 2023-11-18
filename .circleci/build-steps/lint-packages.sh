#!/usr/bin/env bash

declare -a package_recipes
for repo_path in $(jq --raw-output 'keys | .[]' repo.json); do
    repo=$(jq --raw-output '.["'${repo_path}'"].name' repo.json)
    if [ -f ./built_${repo}_packages.txt ]; then
        package_recipes="$package_recipes $(cat ./built_${repo}_packages.txt | repo_path=${repo_path} awk '{print ENVIRON["repo_path"]"/"$1"/build.sh"}')"
    fi
done
if [ ! -z "$package_recipes" ]; then
    ./scripts/lint-packages.sh $package_recipes
fi

# Common auto-update logic for Bazel packages (bazelN).
#
# Usage in build.sh:
#
# 	source "$TERMUX_SCRIPTDIR/common-files/package-update-scripts/update-bazel.sh"
#
# 	termux_pkg_auto_update() {
# 		tur_pkg_update_bazel <major_version>
# 	}
#
# Requires: curl, jq (from termux-packages scripts environment).

tur_pkg_update_bazel() {
	local major_version="$1"
	local tags_api="https://api.github.com/repos/bazelbuild/bazel/git/refs/tags"

	local latest_version=$(
		curl -s "$tags_api" | jq -r '.[].ref' | cut -d'/' -f3 |
			grep "^${major_version}\." | grep -v -E "(rc)|(pre)" |
			sort -V | tail -n1
	)

	if [[ -z "${latest_version}" ]]; then
		echo "WARN: Unable to get latest refs tags from upstream. Try again later." >&2
		return
	fi

	local release_api="https://api.github.com/repos/bazelbuild/bazel/releases/tags/${latest_version}"
	local has_dist=$(
		curl -fsSL "$release_api" 2>/dev/null |
			jq -r --arg dist "bazel-${latest_version}-dist.zip" '
				.assets[]?.name // empty | select(. == $dist)
			' | head -n1
	)

	if [[ -z "$has_dist" ]]; then
		echo "WARN: Latest version ${latest_version} does not have dist archive. Try again later." >&2
		return
	fi

	termux_pkg_upgrade_version "${latest_version}"
}

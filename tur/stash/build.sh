TERMUX_PKG_HOMEPAGE=https://stashapp.cc
TERMUX_PKG_DESCRIPTION="Locally hosted web-based app written in Go which organizes and serves your Adult Video"
TERMUX_PKG_LICENSE="AGPL-V3"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="0.27.2"
TERMUX_PKG_SRCURL=https://github.com/stashapp/stash/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=23402a61329d3c57f0d161e469b07a14a7672f799ff9d97bf082c1b67ace2dea
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_TAG_TYPE="latest-release-tag"

_WEBUI_URL=https://github.com/stashapp/stash/releases/download/v$TERMUX_PKG_VERSION/stash-ui.zip
_WEBUI_SHA256=93b849c947e60f7f935d606c3a36a335966c557960ddb980cf1ed79ce97a724f

termux_pkg_auto_update() {
	local latest_tag
	latest_tag="$(termux_github_api_get_tag "https://github.com/stashapp/stash" "${TERMUX_PKG_UPDATE_TAG_TYPE}")"
	(( ${#latest_tag} )) || {
		printf '%s\n' \
		'WARN: Auto update failure!' \
		"latest_tag=${latest_tag}"
	return
	} >&2

	if [[ "${latest_tag}" == "${TERMUX_PKG_VERSION}" ]]; then
		echo "INFO: No update needed. Already at version '${TERMUX_PKG_VERSION}'."
		return
	fi

	local tmpdir
	tmpdir="$(mktemp -d)"
	curl -sLo "${tmpdir}/tmpfile" "https://github.com/stashapp/stash/releases/download/v$latest_tag/stash-ui.zip"
	local sha="$(sha256sum "${tmpdir}/tmpfile" | cut -d ' ' -f 1)"

	sed \
		-e "s|^_WEBUI_SHA256=.*|_WEBUI_SHA256=${sha}|" \
		-i "${TERMUX_PKG_BUILDER_DIR}/build.sh"

	rm -fr "${tmpdir}"

	printf '%s\n' 'INFO: Generated checksums:' "${sha}"
	termux_pkg_upgrade_version "${latest_tag}"
}

termux_step_post_get_source() {
	mkdir -p ui/v2.5/build
	unzip -d ui/v2.5/build $TERMUX_PKG_CACHEDIR/stash-ui.zip

	termux_setup_golang
	go get -u golang.org/x/tools
	go mod tidy
	GODEBUG=gotypesalias=0 go generate ./cmd/stash
}

termux_step_make() {
	termux_setup_golang

	go build -o stash -v \
		-tags "sqlite_stat4 sqlite_math_functions" \
		-buildmode=pie \
		-trimpath \
		-ldflags="-s -w -linkmode=external \
		-X 'github.com/stashapp/stash/internal/build.buildstamp=$(date +%Y-%m-%d)' \
		-X 'github.com/stashapp/stash/internal/build.githash=$(shell git rev-parse --short HEAD 2>/dev/null || echo unknown)' \
		-X 'github.com/stashapp/stash/internal/build.version=v${TERMUX_PKG_VERSION}' \
		-X 'github.com/stashapp/stash/internal/build.officialBuild=false'" \
		-mod=readonly \
		-modcacherw \
		./cmd/stash
}

termux_step_make_install() {
	install -Dm700 -t "${TERMUX_PREFIX}"/bin "$TERMUX_PKG_SRCDIR"/stash
}

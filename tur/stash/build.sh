TERMUX_PKG_HOMEPAGE=https://stashapp.cc
TERMUX_PKG_DESCRIPTION="Locally hosted web-based app written in Go which organizes and serves your Adult Video"
TERMUX_PKG_LICENSE="AGPL-V3"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="0.28.1"
TERMUX_PKG_SRCURL=git+https://github.com/stashapp/stash
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_TAG_TYPE="latest-release-tag"
TERMUX_PKG_HOSTBUILD=true

termux_step_post_get_source() {
	# Remove this marker all the time
	rm -rf $TERMUX_HOSTBUILD_MARKER
}

termux_step_host_build() {
	termux_setup_nodejs

	mkdir -p _yarn_bin/
	cd _yarn_bin
	npm install yarn
	export PATH="$TERMUX_PKG_HOSTBUILD_DIR/_yarn_bin/node_modules/.bin:$PATH"

	cd $TERMUX_PKG_SRCDIR
	mkdir -p ui/v2.5/build
	cd ui/v2.5
	export VITE_APP_DATE=$(date +%Y-%m-%d)
	export VITE_APP_GITHASH=$(git rev-parse --short HEAD 2>/dev/null)
	export VITE_APP_STASH_VERSION=v${TERMUX_PKG_VERSION}
	yarn install --frozen-lockfile
	touch build/index.html
	cd -

	termux_setup_golang
	go get -u golang.org/x/tools
	go mod tidy
	GODEBUG=gotypesalias=0 go generate ./cmd/stash

	cd ui/v2.5
	yarn run gqlgen
	yarn build
}

termux_step_make() {
	termux_setup_golang

	go build -o stash -v \
		-tags "sqlite_stat4 sqlite_math_functions" \
		-buildmode=pie \
		-trimpath \
		-ldflags="-s -w -linkmode=external \
		-X 'github.com/stashapp/stash/internal/build.buildstamp=$(date +%Y-%m-%d)' \
		-X 'github.com/stashapp/stash/internal/build.githash=$(git rev-parse --short HEAD 2>/dev/null)' \
		-X 'github.com/stashapp/stash/internal/build.version=v${TERMUX_PKG_VERSION}' \
		-X 'github.com/stashapp/stash/internal/build.officialBuild=false'" \
		-mod=readonly \
		-modcacherw \
		./cmd/stash
}

termux_step_make_install() {
	install -Dm700 -t "${TERMUX_PREFIX}"/bin "$TERMUX_PKG_SRCDIR"/stash
}

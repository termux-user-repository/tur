TERMUX_PKG_HOMEPAGE=https://stashapp.cc
TERMUX_PKG_DESCRIPTION="Locally hosted web-based app written in Go which organizes and serves your Adult Video"
TERMUX_PKG_LICENSE="AGPL-V3"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="0.27.2"
TERMUX_PKG_SRCURL=https://github.com/stashapp/stash/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=23402a61329d3c57f0d161e469b07a14a7672f799ff9d97bf082c1b67ace2dea
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_HOSTBUILD=true

termux_step_host_build() {
	termux_setup_nodejs

	cp -r $TERMUX_PKG_SRCDIR ./stash
	mkdir -p stash/ui/v2.5/build
	cd stash/ui/v2.5
	export VITE_APP_DATE=$(date +%Y-%m-%d)
	export VITE_APP_GITHASH=$(shell git rev-parse --short HEAD 2>/dev/null || echo unknown)
	export VITE_APP_STASH_VERSION=v${TERMUX_PKG_VERSION}
	yarnpkg install --frozen-lockfile
	touch build/index.html
	cd ../..
	go generate ./cmd/stash
	cd ui/v2.5
	yarnpkg run gqlgen
	yarnpkg build
}

termux_step_pre_configure() {
	cp -r $TERMUX_PKG_HOSTBUILD_DIR/stash $TERMUX_PKG_SRCDIR/stash
	termux_setup_golang
}

termux_step_make() {
	cd stash
	export CGO_ENABLED=1
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
	install -Dm700 -t "${TERMUX_PREFIX}"/bin "$TERMUX_PKG_SRCDIR"/stash/stash
}

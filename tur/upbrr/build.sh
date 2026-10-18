TERMUX_PKG_HOMEPAGE="https://upbrr.com"
TERMUX_PKG_DESCRIPTION="Guided upload preparation app for private-tracker workflows"
TERMUX_PKG_LICENSE="GPL-2.0-or-later"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="0.4.0"
TERMUX_PKG_SRCURL="https://github.com/autobrr/upbrr/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=de9733fa408f818f41f6c7e19cc56de3f9864b9f6e25d05e51da03c5066deb8f
TERMUX_PKG_DEPENDS="ffmpeg"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_TAG_TYPE="latest-release-tag"
TERMUX_PKG_HOSTBUILD=true
TERMUX_PKG_SERVICE_SCRIPT=(
	"upbrr"
	"exec ${TERMUX_PREFIX}/bin/upbrr serve 2>&1"
)

termux_step_post_get_source() {
	rm -rf "$TERMUX_HOSTBUILD_MARKER"
}

termux_step_host_build() {
	termux_setup_nodejs

	if ! command -v pnpm >/dev/null 2>&1; then
		npm install --prefix "$TERMUX_PKG_HOSTBUILD_DIR" pnpm
		export PATH="$TERMUX_PKG_HOSTBUILD_DIR/node_modules/.bin:$PATH"
	fi

	export PNPM_CONFIG_PM_ON_FAIL=ignore

	cd "$TERMUX_PKG_SRCDIR/webui"
	pnpm install --frozen-lockfile
	pnpm run build

	cd "$TERMUX_PKG_SRCDIR"
	sh scripts/sync-webui-assets.sh
}

termux_step_make() {
	termux_setup_golang

	local ldflags="-w -s -X main.version=v${TERMUX_PKG_VERSION}"

	go build -trimpath -ldflags="${ldflags}" -o bin/upbrr ./cmd/upbrr
}

termux_step_make_install() {
	install -Dm755 -t "${TERMUX_PREFIX}/bin" bin/upbrr
}

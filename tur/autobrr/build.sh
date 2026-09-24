TERMUX_PKG_HOMEPAGE="https://autobrr.com"
TERMUX_PKG_DESCRIPTION="The modern download automation tool for torrents and usenet"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="1.86.0"
TERMUX_PKG_SRCURL="https://github.com/autobrr/autobrr/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256="97fda65127c6d0754b6dd990df40ba0cc4a2a0064a6c460f59e5a9f83f72293c"
TERMUX_PKG_BUILD_DEPENDS="nodejs"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_TAG_TYPE="latest-release-tag"
TERMUX_PKG_SERVICE_SCRIPT=(
	"autobrr"
	"exec ${TERMUX_PREFIX}/bin/autobrr --config ${TERMUX_ANDROID_HOME}/.config/autobrr 2>&1"
)

termux_step_make() {
	termux_setup_golang
	termux_setup_nodejs

	if ! command -v pnpm >/dev/null 2>&1; then
		local pnpm_dir="$TERMUX_PKG_TMPDIR/pnpm"
		mkdir -p "$pnpm_dir"
		npm install --prefix "$pnpm_dir" pnpm
		export PATH="$pnpm_dir/node_modules/.bin:$PATH"
	fi

	# Prevent pnpm from trying to download unsupported @pnpm/exe for android-arm64
	sed -i '/"packageManager":/d' web/package.json

	pnpm --dir web install --frozen-lockfile
	pnpm --dir web run build

	local ldflags="-w -s -X main.version=v${TERMUX_PKG_VERSION}"

	go build -ldflags="${ldflags}" -o bin/autobrr cmd/autobrr/main.go
	go build -ldflags="${ldflags}" -o bin/autobrrctl cmd/autobrrctl/main.go
}

termux_step_make_install() {
	install -Dm755 -t "${TERMUX_PREFIX}/bin" bin/autobrr bin/autobrrctl
	install -Dm644 docs/man/autobrr.1 "${TERMUX_PREFIX}/share/man/man1/autobrr.1"
}

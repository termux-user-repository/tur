TERMUX_PKG_HOMEPAGE=https://github.com/hr3lxphr6j/bililive-go
TERMUX_PKG_DESCRIPTION="A live streaming recording tool"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="2096779623 <admin@utermux.dev>"
TERMUX_PKG_VERSION="0.7.22"
TERMUX_PKG_SRCURL=https://github.com/hr3lxphr6j/bililive-go/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=43bc7edf2ca4a3e338ee202fca3fb48eb97230e64a68738ba628903df15cb5fe
TERMUX_PKG_BUILD_DEPENDS="yarn"
TERMUX_PKG_DEPENDS="ffmpeg"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	termux_setup_golang
	termux_setup_nodejs

	go mod init || :
	go mod tidy
}

termux_step_make() {
	cd "$TERMUX_PKG_SRCDIR"/src/webapp && "$TERMUX_PREFIX"/bin/yarn install && "$TERMUX_PREFIX"/bin/yarn build && cd ../../
	local _date=$(date '+%Y-%m-%d_%H:%M:%S')
	ldflags="\
	-X 'github.com/hr3lxphr6j/bililive-go/src/consts.BuildTime=$_date' \
	-X github.com/hr3lxphr6j/bililive-go/src/consts.AppVersion=v${TERMUX_PKG_VERSION} \
	-X github.com/hr3lxphr6j/bililive-go/src/consts.GitHash=$(git ls-remote https://github.com/hr3lxphr6j/bililive-go refs/tags/v${TERMUX_PKG_VERSION}|cut -f1) \
	"
	CGO_ENABLED=0 go build -tags "release" -o "$TERMUX_PKG_SRCDIR"/bililive-go -ldflags="$ldflags" "$TERMUX_PKG_SRCDIR"/src/cmd/bililive/
}

termux_step_make_install() {
	install -Dm700 -t "${TERMUX_PREFIX}"/bin "$TERMUX_PKG_SRCDIR"/bililive-go
}

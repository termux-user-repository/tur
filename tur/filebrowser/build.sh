TERMUX_PKG_HOMEPAGE=https://filebrowser.org/
TERMUX_PKG_DESCRIPTION="Web file browser based on Go"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="2.34.1"
TERMUX_PKG_SRCURL="https://github.com/filebrowser/filebrowser/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=a1c2780259f96a282fe01e4fd43b179c8a86f1dabc8b377722beff7c80ad6274
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_HOSTBUILD=true

termux_step_post_get_source() {
	termux_setup_golang
	go mod vendor
}

termux_step_host_build() {
	if [ -e "$TERMUX_PREFIX/bin" ]; then
		rm -rf $TERMUX_PREFIX/bin.bp
		mv -f $TERMUX_PREFIX/bin $TERMUX_PREFIX/bin.bp
	fi
	termux_setup_nodejs
	npm install pnpm
	export PATH="$TERMUX_PKG_HOSTBUILD_DIR/node_modules/.bin:$PATH"
	if [ -e "$TERMUX_PREFIX/bin.bp" ]; then
		rm -rf $TERMUX_PREFIX/bin
		mv -f $TERMUX_PREFIX/bin.bp $TERMUX_PREFIX/bin
	fi
}

termux_step_configure() {
	termux_setup_golang
	termux_setup_nodejs
	export PATH="$TERMUX_PKG_HOSTBUILD_DIR/node_modules/.bin:$PATH"
}

termux_step_make() {
	local _commit_hash=$(
		curl https://api.github.com/repos/filebrowser/filebrowser/git/ref/tags/v$TERMUX_PKG_VERSION \
		| jq -r .object.sha
	)
	local _module_name=$(env GO111MODULE=on go list -m)
	make build-frontend
	go build -ldflags="-X $_module_name/version.Version=$TERMUX_PKG_VERSION -X $_module_name/version.CommitSHA=$_commit_hash"
}

termux_step_make_install() {
	install -Dm700 filebrowser $TERMUX_PREFIX/bin/
}

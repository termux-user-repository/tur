TERMUX_PKG_HOMEPAGE=https://github.com/JayXon/Leanify
TERMUX_PKG_DESCRIPTION="Lightweight lossless file minifier/optimize"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
_COMMIT=42770e600b32962e7110c24b5fcaa8c7c2144b17
_COMMIT_DATE="2025.05.20"
TERMUX_PKG_VERSION="0.4.3+${_COMMIT_DATE//./}"
TERMUX_PKG_SHA256=577570909d148a5a0abc4e09fa30250dbd51eb14b834ce4526af4dc27626dc09
TERMUX_PKG_GIT_BRANCH=master
TERMUX_PKG_SRCURL=git+https://github.com/JayXon/Leanify.git
TERMUX_PKG_DEPENDS='libiconv'
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_post_get_source() {
	git fetch --unshallow
	git checkout "$_COMMIT"

	local commit_date
	commit_date="$(git log -1 --format=%cs | sed 's/-/./g')"
	if [[ "$commit_date" != "$_COMMIT_DATE" ]]; then
		echo -n "ERROR: The specified commit date \"$_COMMIT_DATE\""
		echo " is different from what is expected to be: \"$commit_date\""
		return 1
	fi

	local sha256
	sha256=$(find . -type f ! -path '*/.git/*' -print0 | xargs -0 sha256sum | LC_ALL=C sort | sha256sum)
	if [[ "${sha256}" != "${TERMUX_PKG_SHA256}  "* ]]; then
		termux_error_exit "Checksum mismatch for source files. Got: ${sha256::64}"
	fi
}

termux_step_post_configure() {
	LDFLAGS+=' -liconv'
	CFLAGS+=' -Wno-error=unused-but-set-variable'
	if [[ "${TERMUX_ARCH_BITS}" == '32' ]]; then
		CFLAGS+=' -Wno-error=format'
	fi
}

# Makefile includes no install target
termux_step_make_install() {
	install -Dm755 -t "$TERMUX_PREFIX/bin" "${TERMUX_PKG_SRCDIR}/leanify"
}

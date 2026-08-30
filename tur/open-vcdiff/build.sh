TERMUX_PKG_HOMEPAGE="https://github.com/google/open-vcdiff"
TERMUX_PKG_DESCRIPTION="An encoder/decoder for the VCDIFF (RFC3284) format"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
_SUBTREE_COMMIT_DATEREV=20190311
_SUBTREE_COMMIT=868f459a8d815125c2457f8c74b12493853100f9
TERMUX_PKG_VERSION="0.8.4.git$_SUBTREE_COMMIT_DATEREV"
TERMUX_PKG_SRCURL="git+https://github.com/google/open-vcdiff"
TERMUX_PKG_SHA256=SKIP_CHECKSUM
TERMUX_PKG_GIT_BRANCH=master
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DCMAKE_POLICY_VERSION_MINIMUM=3.5
"

termux_step_post_get_source() {
	git fetch --unshallow

	local testCommit="$(git log --format=%H -1)"
	local testCommitDateRev="$(TZ=UTC git log --date=format:%Y%m%d --format=%cd | head -n1)"

	if [ "$_SUBTREE_COMMIT_DATEREV/$_SUBTREE_COMMIT" != "$testCommitDateRev/$testCommit" ]; then
		termux_error_exit "outdated \$_SUBTREE_COMMIT_DATEREV/\$_SUBTREE_COMMIT defined in $TERMUX_PKG_NAME/build.sh ($_SUBTREE_COMMIT_DATEREV/$_SUBTREE_COMMIT)"
	fi
}

termux_step_post_make_install() {
	cd "$TERMUX_PKG_SRCDIR"
	install -Dm644 -t "$TERMUX_PREFIX/share/doc/$TERMUX_PKG_NAME" README.md
}

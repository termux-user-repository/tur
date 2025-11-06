TERMUX_PKG_HOMEPAGE=https://gawkextlib.sourceforge.net/mbs/mbs.html
TERMUX_PKG_DESCRIPTION="gawk(1) extension library providing functions for working with strings in a byte-oriented manner (in case of running under multibyte locales)"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@flosnvjx"
_SUBTREE_COMMIT_DATEREV=20240116
_SUBTREE_COMMIT=ae6711872ed50be5712baa3f9f57810c93bf4219
_SUBTREE_COMMIT_STICK=1
TERMUX_PKG_VERSION="1.0.0.git$_SUBTREE_COMMIT_DATEREV"
## use git repo as source since upstream hasn't make a release tarball for mbs
TERMUX_PKG_SRCURL="git+https://git.code.sf.net/p/gawkextlib/code"
TERMUX_PKG_GIT_BRANCH=master
TERMUX_PKG_SHA256=SKIP_CHECKSUM
TERMUX_PKG_DEPENDS="gawk"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="ac_cv_header_libintl_h=no"

termux_step_post_get_source() {
	git fetch --unshallow

	local testCommit="$(git log --format=%H -1 -- mbs/ shared/)"
	local testCommitDateRev="$(TZ=UTC git log --date=format:%Y%m%d --format=%cd -- mbs/ shared/ | uniq -c | awk '{if ($1>1) {print ($2 ".r" ($1-1));} else print $2; exit;}')"

	if [ -n "$testCommitDateRev" ] && [ -n "$testCommit" ]; then
		if [ "$_SUBTREE_COMMIT_DATEREV/$_SUBTREE_COMMIT" != "$testCommitDateRev/$testCommit" ]; then
			if [ "$_SUBTREE_COMMIT_STICK" -gt 0 ]; then
				printf "%s\n" "potential outdated \$_SUBTREE_COMMIT_DATEREV/\$_SUBTREE_COMMIT defined in $TERMUX_PKG_NAME/build.sh ($_SUBTREE_COMMIT_DATEREV/$_SUBTREE_COMMIT)" > /dev/stderr
			else
				termux_error_exit "outdated \$_SUBTREE_COMMIT_DATEREV/\$_SUBTREE_COMMIT defined in $TERMUX_PKG_NAME/build.sh ($_SUBTREE_COMMIT_DATEREV/$_SUBTREE_COMMIT)"
			fi
		fi
	else
		termux_error_exit "missing subtree mbs/,shared/ in source repo"
	fi

	git checkout "$_SUBTREE_COMMIT"
}

termux_step_pre_configure() {
	TERMUX_PKG_SRCDIR="$TERMUX_PKG_SRCDIR/mbs"

	cd "$TERMUX_PKG_SRCDIR"
	autoreconf -fi
}

termux_step_post_make_install() {
	cd "$TERMUX_PKG_SRCDIR"
	install -Dm644 -t "$TERMUX_PREFIX/share/doc/$TERMUX_PKG_NAME" test/mbs.awk
}

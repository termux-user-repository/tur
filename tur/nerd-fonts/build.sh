TERMUX_PKG_HOMEPAGE=https://www.nerdfonts.com/
TERMUX_PKG_DESCRIPTION="Meta package that installs all Nerd Fonts patched font packages provided by TUR"
TERMUX_PKG_LICENSE="OFL-1.1, MIT, Apache-2.0"
TERMUX_PKG_MAINTAINER="Gouranga Das Samrat <gouranga.das.khulna@gmail.com>"
TERMUX_PKG_VERSION=3.5.1
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_REVISION=1
TERMUX_PKG_PLATFORM_INDEPENDENT=true

## TERMUX_PKG_SRCURL/TERMUX_PKG_SHA256 point at the tagged source tarball of
## the whole nerd-fonts repo purely so the "github" auto-update method (see
## scripts/updates/termux_pkg_auto_update.sh) has a TERMUX_PKG_SRCURL to
## match against github.com and infer the update method/check for new tags
## from - TERMUX_PKG_AUTO_UPDATE=true with no TERMUX_PKG_SRCURL at all makes
## that script fail with "TERMUX_PKG_SRCURL: unbound variable" /
## "wrong value '' for TERMUX_PKG_UPDATE_METHOD".
## TERMUX_PKG_SKIP_SRC_EXTRACT=true below means this tarball is never
## actually downloaded/extracted during a normal build - see the note above
## the font table for why: every font family instead ships as its own flat
## *.ttf zip from the same release, downloaded individually below.
TERMUX_PKG_SRCURL=https://github.com/ryanoasis/nerd-fonts/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=81627f9e1d79c5028e2ac28a011b46dc335e146c6ce9d0c368f28c5c3601955a
TERMUX_PKG_SKIP_SRC_EXTRACT=true

# All Nerd Fonts font families ship as separate flat *.ttf archives from the
# same upstream release. This package doesn't build from TERMUX_PKG_SRCURL
# above (that's only there for auto-update, see note above): every font's
# archive is instead downloaded (and its sha256 verified) with the
# termux_download helper inside termux_step_make_install() below, and unpacked
# per-font from there. Every font's own files then move into its own
# ttf-*-nerd subpackage (see the *.subpackage.sh files next to this build.sh),
# so this "nerd-fonts" package itself ends up with no files of its own - it
# only depends on all of them, acting as a convenience "install everything"
# meta package. Each ttf-*-nerd subpackage can still be installed on its own,
# without pulling this meta package in.
TERMUX_PKG_DEPENDS="ttf-cascadia-code-nerd, ttf-hack-nerd, ttf-inconsolata-nerd, ttf-jetbrains-mono-nerd, ttf-meslo-nerd, ttf-roboto-mono-nerd, ttf-sourcecodepro-nerd, ttf-victor-mono-nerd"

termux_step_make_install() {
	local fonts_dir="$TERMUX_PREFIX/share/fonts/TTF"
	mkdir -p "$fonts_dir"

	## Table of "<subpackage name>|<upstream zip basename>|<sha256 of the
	## zip>|<license file name inside the zip>|<nerd-fonts family file
	## prefix>|<styles to keep>".
	## NOTE: only Regular/Bold/Italic/BoldItalic styles are kept (where
	## upstream provides them) to keep each subpackage size reasonable.
	## NOTE: Inconsolata Nerd Font only ships Regular and Bold - there is no
	## Italic/BoldItalic .ttf in that release.
	## termux_download() writes into $TERMUX_PKG_CACHEDIR, but that directory
	## is normally only created by the generic TERMUX_PKG_SRCURL source-fetch
	## step - which this package skips (TERMUX_PKG_SKIP_SRC_EXTRACT=true,
	## no TERMUX_PKG_SRCURL). Make sure it exists before downloading into it.
	mkdir -p "$TERMUX_PKG_CACHEDIR"

	local font
	for font in \
		"ttf-cascadia-code-nerd|CascadiaCode|1298bf92698afa06185cf1d05e6ae05f2d8a1e8c3cb45ddf4c3035168ab342a1|LICENSE|CaskaydiaCoveNerdFont|Regular Bold Italic BoldItalic" \
		"ttf-hack-nerd|Hack|fa24da7de7cefe7766614d27762570b20453c852fc1d5b657111666df9a5e449|LICENSE.md|HackNerdFont|Regular Bold Italic BoldItalic" \
		"ttf-inconsolata-nerd|Inconsolata|de7bf85382dad8c239696b7ccddd3e69c5a79b77c6d18c6abe9d6676d28a8764|OFL.txt|InconsolataNerdFont|Regular Bold" \
		"ttf-jetbrains-mono-nerd|JetBrainsMono|fab782a66f7d3019da64f6572db9fc5d3a4bcb19f9fa13e2d8a62e3693d6396e|OFL.txt|JetBrainsMonoNerdFont|Regular Bold Italic BoldItalic" \
		"ttf-meslo-nerd|Meslo|fb104893ecd8f57e8afacbc0a7086b42657120448d056d6093c728a9afb8e237|LICENSE.txt|MesloLGSNerdFont|Regular Bold Italic BoldItalic" \
		"ttf-roboto-mono-nerd|RobotoMono|b5db570b0b2bf5a3a62911aeefd2c8df91a12dcb66261169e7353f984002d5b7|LICENSE.txt|RobotoMonoNerdFont|Regular Bold Italic BoldItalic" \
		"ttf-sourcecodepro-nerd|SourceCodePro|e0000bc77cd77279840d8613e98727548f81f291a571be0be8699c8e3be36fd3|LICENSE.txt|SauceCodeProNerdFont|Regular Bold Italic BoldItalic" \
		"ttf-victor-mono-nerd|VictorMono|81cf501f80581bc2e73f70264441cf96980736a4bbb07c090996af6ab8f19013|LICENSE.txt|VictorMonoNerdFont|Regular Bold Italic BoldItalic" \
	; do
		local pkg_name zip_name zip_sha256 license_name font_prefix styles
		IFS='|' read -r pkg_name zip_name zip_sha256 license_name font_prefix styles <<< "$font"

		## Download (and sha256-verify) this font's release zip into the
		## package cache dir - termux_download skips re-downloading if a
		## file with a matching checksum is already cached there.
		local zip_file="$TERMUX_PKG_CACHEDIR/${zip_name}.zip"
		if ! termux_download \
			"https://github.com/ryanoasis/nerd-fonts/releases/download/v${TERMUX_PKG_VERSION}/${zip_name}.zip" \
			"$zip_file" \
			"$zip_sha256"
		then
			echo "ERROR: termux_download failed for ${zip_name}.zip (pkg_name=$pkg_name)" 1>&2
			return 1
		fi

		## Belt-and-suspenders: termux_download() always returns 0 as its
		## last statement even when the final `mv` into place failed (e.g.
		## if $TERMUX_PKG_CACHEDIR didn't exist yet), so its own exit code
		## can't be trusted alone. Confirm the file is really there and
		## non-empty before handing it to unzip, so a download problem
		## shows up as a clear message here instead of a confusing
		## "cannot find or open" error out of unzip.
		if [ ! -s "$zip_file" ]; then
			echo "ERROR: expected downloaded file missing or empty: $zip_file" 1>&2
			return 1
		fi

		## The release zip is a flat archive of *.ttf files (no subfolders),
		## so a plain unzip into a scratch dir is enough.
		local extract_dir
		extract_dir=$(mktemp -d)
		unzip -q "$zip_file" -d "$extract_dir"

		local style
		for style in $styles; do
			cp "$extract_dir/${font_prefix}-${style}.ttf" "$fonts_dir/"
		done

		## Keep this font's own upstream license next to its own files so it
		## travels with its ttf-*-nerd subpackage, not with this meta package.
		mkdir -p "$TERMUX_PREFIX/share/doc/$pkg_name"
		cp "$extract_dir/$license_name" "$TERMUX_PREFIX/share/doc/$pkg_name/LICENSE"

		rm -rf "$extract_dir"
	done
}

## The generic termux_step_install_license (run by build-package.sh right
## after termux_step_make_install) tries to auto-detect a license file for
## every license listed in TERMUX_PKG_LICENSE by looking inside
## $TERMUX_PKG_SRCDIR. This package sets TERMUX_PKG_SKIP_SRC_EXTRACT=true and
## never populates $TERMUX_PKG_SRCDIR, so that lookup always fails - hence
## "ERROR: nerd-fonts: Could not find a license file for OFL-1.1 in the
## package sources" on every arch.
## It isn't needed anyway: this meta package ends up with no files of its
## own (everything is claimed by the eight ttf-*-nerd subpackages via
## TERMUX_SUBPKG_INCLUDE), and each subpackage already gets its own upstream
## license copied into share/doc/<subpkg>/LICENSE directly above in
## termux_step_make_install(). So skip the generic step entirely.
termux_step_install_license() {
	return
}

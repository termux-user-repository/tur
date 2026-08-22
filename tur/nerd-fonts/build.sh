TERMUX_PKG_HOMEPAGE=https://www.nerdfonts.com/
TERMUX_PKG_DESCRIPTION="Meta package that installs all Nerd Fonts patched font packages provided by TUR"
TERMUX_PKG_LICENSE="OFL-1.1, MIT, Apache-2.0"
TERMUX_PKG_MAINTAINER="Gouranga Das Samrat <gouranga.das.khulna@gmail.com>"
TERMUX_PKG_VERSION=3.5.1
# The first entry is for the auto-update system to fetch the latest release tarball, the rest are the upstream font zips.
TERMUX_PKG_SRCURL=(
	https://github.com/ryanoasis/nerd-fonts/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
	https://github.com/ryanoasis/nerd-fonts/releases/download/v${TERMUX_PKG_VERSION}/CascadiaCode.zip
	https://github.com/ryanoasis/nerd-fonts/releases/download/v${TERMUX_PKG_VERSION}/Hack.zip
	https://github.com/ryanoasis/nerd-fonts/releases/download/v${TERMUX_PKG_VERSION}/Inconsolata.zip
	https://github.com/ryanoasis/nerd-fonts/releases/download/v${TERMUX_PKG_VERSION}/JetBrainsMono.zip
	https://github.com/ryanoasis/nerd-fonts/releases/download/v${TERMUX_PKG_VERSION}/Meslo.zip
	https://github.com/ryanoasis/nerd-fonts/releases/download/v${TERMUX_PKG_VERSION}/RobotoMono.zip
	https://github.com/ryanoasis/nerd-fonts/releases/download/v${TERMUX_PKG_VERSION}/SourceCodePro.zip
	https://github.com/ryanoasis/nerd-fonts/releases/download/v${TERMUX_PKG_VERSION}/VictorMono.zip
)
TERMUX_PKG_SHA256=(
	81627f9e1d79c5028e2ac28a011b46dc335e146c6ce9d0c368f28c5c3601955a
	1298bf92698afa06185cf1d05e6ae05f2d8a1e8c3cb45ddf4c3035168ab342a1
	fa24da7de7cefe7766614d27762570b20453c852fc1d5b657111666df9a5e449
	de7bf85382dad8c239696b7ccddd3e69c5a79b77c6d18c6abe9d6676d28a8764
	fab782a66f7d3019da64f6572db9fc5d3a4bcb19f9fa13e2d8a62e3693d6396e
	fb104893ecd8f57e8afacbc0a7086b42657120448d056d6093c728a9afb8e237
	b5db570b0b2bf5a3a62911aeefd2c8df91a12dcb66261169e7353f984002d5b7
	e0000bc77cd77279840d8613e98727548f81f291a571be0be8699c8e3be36fd3
	81cf501f80581bc2e73f70264441cf96980736a4bbb07c090996af6ab8f19013
)
TERMUX_PKG_PLATFORM_INDEPENDENT=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_DEPENDS="ttf-cascadia-code-nerd, ttf-hack-nerd, ttf-inconsolata-nerd, ttf-jetbrains-mono-nerd, ttf-meslo-nerd, ttf-roboto-mono-nerd, ttf-sourcecodepro-nerd, ttf-victor-mono-nerd"

termux_step_get_source() {
	# Skip fetch the first entry since it is only used for auto-update
	local i=""
	for i in $(seq 1 $(( ${#TERMUX_PKG_SRCURL[@]}-1 ))); do
		local bname="$(basename "${TERMUX_PKG_SRCURL[$i]}")"
		local file="$TERMUX_PKG_CACHEDIR/${bname}"
		local folder="${bname%.*}"
		termux_download "${TERMUX_PKG_SRCURL[$i]}" "$file" "${TERMUX_PKG_SHA256[$i]}"
		rm -Rf "${TERMUX_PKG_SRCDIR}/${folder}"
		mkdir -p "${TERMUX_PKG_SRCDIR}/${folder}"
		pushd "${TERMUX_PKG_SRCDIR}/${folder}"
		unzip -q "$file"
		popd # "${TERMUX_PKG_SRCDIR}/${folder}"
	done
}

termux_step_make_install() {
	local fonts_dir="$TERMUX_PREFIX/share/fonts/TTF"
	mkdir -p "$fonts_dir"

	## Table of "<subpackage name>|<upstream zip basename>|<license file name
	## inside the zip>|<nerd-fonts family file prefix>|<styles to keep>".
	## NOTE: only Regular/Bold/Italic/BoldItalic styles are kept (where
	## upstream provides them) to keep each subpackage size reasonable.
	## NOTE: Inconsolata Nerd Font only ships Regular and Bold - there is no
	## Italic/BoldItalic .ttf in that release.
	local font
	for font in \
		"ttf-cascadia-code-nerd|CascadiaCode|LICENSE|CaskaydiaCoveNerdFont|Regular Bold Italic BoldItalic" \
		"ttf-hack-nerd|Hack|LICENSE.md|HackNerdFont|Regular Bold Italic BoldItalic" \
		"ttf-inconsolata-nerd|Inconsolata|OFL.txt|InconsolataNerdFont|Regular Bold" \
		"ttf-jetbrains-mono-nerd|JetBrainsMono|OFL.txt|JetBrainsMonoNerdFont|Regular Bold Italic BoldItalic" \
		"ttf-meslo-nerd|Meslo|LICENSE.txt|MesloLGSNerdFont|Regular Bold Italic BoldItalic" \
		"ttf-roboto-mono-nerd|RobotoMono|LICENSE.txt|RobotoMonoNerdFont|Regular Bold Italic BoldItalic" \
		"ttf-sourcecodepro-nerd|SourceCodePro|LICENSE.txt|SauceCodeProNerdFont|Regular Bold Italic BoldItalic" \
		"ttf-victor-mono-nerd|VictorMono|LICENSE.txt|VictorMonoNerdFont|Regular Bold Italic BoldItalic" \
	; do
		local pkg_name zip_name license_name font_prefix styles
		IFS='|' read -r pkg_name zip_name license_name font_prefix styles <<< "$font"

		local extract_dir=${TERMUX_PKG_SRCDIR}/${zip_name}
		local style
		for style in $styles; do
			cp "$extract_dir/${font_prefix}-${style}.ttf" "$fonts_dir/"
		done

		## Keep this font's own upstream license next to its own files so it
		## travels with its ttf-*-nerd subpackage, not with this meta package.
		mkdir -p "$TERMUX_PREFIX/share/doc/$pkg_name"
		cp "$extract_dir/$license_name" "$TERMUX_PREFIX/share/doc/$pkg_name/LICENSE"
	done
}

termux_step_install_license() {
	# LICENSE has been installed in each subpackage
	# Install a generic LICENSE file for this meta package.
	mkdir -p $TERMUX_PREFIX/share/doc/$TERMUX_PKG_NAME
	wget \
		https://raw.githubusercontent.com/ryanoasis/nerd-fonts/refs/tags/v${TERMUX_PKG_VERSION}/LICENSE \
		-O "$TERMUX_PREFIX/share/doc/$TERMUX_PKG_NAME/LICENSE"
}

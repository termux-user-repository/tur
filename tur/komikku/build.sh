TERMUX_PKG_HOMEPAGE=https://apps.gnome.org/Komikku/
TERMUX_PKG_DESCRIPTION="Discover and read manga"
TERMUX_PKG_LICENSE="GPL-3.0-or-later"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=50.9.0
TERMUX_PKG_SRCURL=git+https://codeberg.org/valos/Komikku
TERMUX_PKG_DEPENDS="gdk-pixbuf, glib, gobject-introspection, gtk4, libadwaita, libsoup3, python, pygobject, pycairo, python-pillow, python-brotli, python-lxml, python-cryptography, shared-mime-info, webkitgtk-6.0"
TERMUX_PKG_BUILD_DEPENDS="blueprint-compiler, desktop-file-utils, ninja, python-pip"
TERMUX_PYG_DEPS="beautifulsoup4 colorthief dateparser ebooklib emoji jxlpy keyring natsort piexif PyJWT pypdf python-magic rarfile requests Unidecode tzdata"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	termux_setup_python_pip
	termux_setup_bpc
	pip install --prefix=$TERMUX_PREFIX meson $TERMUX_PYG_DEPS 'pure-protobuf<3.0'
}

termux_step_configure() {
	PYTHONPATH=$TERMUX_PREFIX/lib/python$TERMUX_PYTHON_VERSION/site-packages \
		meson setup _build . \
		--prefix $TERMUX_PREFIX \
		--libdir $TERMUX_PREFIX/lib \
		-Dprofile=default \
		-Dblueprint-compiler:docs=false
}

termux_step_make() {
	PYTHONPATH=$TERMUX_PREFIX/lib/python$TERMUX_PYTHON_VERSION/site-packages \
		ninja -C _build
}

termux_step_make_install() {
	PYTHONPATH=$TERMUX_PREFIX/lib/python$TERMUX_PYTHON_VERSION/site-packages \
		ninja -C _build install
}

termux_step_post_massage() {
	find . -name '*.pyc' -delete 2>/dev/null || true
	find . -type d -name '__pycache__' -exec rm -rf {} + 2>/dev/null || true
}

termux_step_create_debscripts() {
	cat <<- POSTINST_EOF > ./postinst
	#!$TERMUX_PREFIX/bin/bash
	glib-compile-schemas $TERMUX_PREFIX/share/glib-2.0/schemas/
	POSTINST_EOF

	cat <<- PRERM_EOF > ./prerm
	#!$TERMUX_PREFIX/bin/bash
	if [ -z "\$DONT_REMOVE_SCHEMAS" ]; then
		glib-compile-schemas $TERMUX_PREFIX/share/glib-2.0/schemas/
	fi
	PRERM_EOF
}

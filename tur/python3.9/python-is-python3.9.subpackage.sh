TERMUX_SUBPKG_DESCRIPTION="Symlinks python(3) to python$_MAJOR_VERSION"
TERMUX_SUBPKG_BREAKS="python"
TERMUX_SUBPKG_CONFLICTS="python"
TERMUX_SUBPKG_INCLUDE="
bin/python
bin/python3
lib/libpython3.so
"

termux_step_create_subpkg_debscripts() {
	# Post-installation script for installing symlinks of pip.
	cat <<- POSTINST_EOF > ./postinst
	#!$TERMUX_PREFIX/bin/sh

	echo "Installing symlinks of pip..."

	ln -sfr $TERMUX_PREFIX/bin/pip${_MAJOR_VERSION} $TERMUX_PREFIX/bin/pip
	ln -sfr $TERMUX_PREFIX/bin/pip${_MAJOR_VERSION} $TERMUX_PREFIX/bin/pip3

	exit 0
	POSTINST_EOF

	# Pre-rm script to cleanup symlinks of pip.
	cat <<- PRERM_EOF > ./prerm
	#!$TERMUX_PREFIX/bin/sh

	if [ "$TERMUX_PACKAGE_FORMAT" != "pacman" ] && [ "\$1" != "remove" ]; then
	    exit 0
	fi

	echo "Deleting symlinks of pip..."

	rm -f $TERMUX_PREFIX/bin/pip
	rm -f $TERMUX_PREFIX/bin/pip3

	exit 0
	PRERM_EOF

	chmod 0755 postinst prerm
}

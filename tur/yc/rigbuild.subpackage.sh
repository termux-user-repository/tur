TERMUX_SUBPKG_DESCRIPTION="The Rig build system"
TERMUX_SUBPKG_INCLUDE=""

termux_step_create_subpkg_debscripts() {
	cat <<- EOF > ./postinst
	#!$TERMUX_PREFIX/bin/sh
	ln -sf ./yc $TERMUX_PREFIX/bin/rig
	ln -sf ./yc $TERMUX_PREFIX/bin/rigr
	ln -sf ./yc $TERMUX_PREFIX/bin/rigc
	chmod 700 $TERMUX_PREFIX/bin/rig{r,c,}
	exit 0
	EOF
	cat <<- EOF > ./prerm
	#!$TERMUX_PREFIX/bin/sh
	rm -f $TERMUX_PREFIX/bin/rig{r,c,}
	exit 0
	EOF
}

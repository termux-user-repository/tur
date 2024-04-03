TERMUX_SUBPKG_DESCRIPTION="The Yao programming language"
TERMUX_SUBPKG_INCLUDE="bin/yc"

termux_step_create_subpkg_debscripts() {
	cat <<- EOF > ./postinst
	#!$TERMUX_PREFIX/bin/sh
	ln -sf ./yc $TERMUX_PREFIX/bin/yao
	chmod 700 $TERMUX_PREFIX/bin/yao
	exit 0
	EOF
	cat <<- EOF > ./prerm
	#!$TERMUX_PREFIX/bin/sh
	rm -f $TERMUX_PREFIX/bin/yao
	exit 0
	EOF
}

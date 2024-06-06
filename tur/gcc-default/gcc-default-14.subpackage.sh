TERMUX_SUBPKG_DESCRIPTION="Use GNU Compiler Collections as default compiler suit (Version 14)"
TERMUX_SUBPKG_DEPEND_ON_PARENT=no
TERMUX_SUBPKG_DEPENDS="gcc-14"
TERMUX_SUBPKG_BREAKS="gcc-default-9, gcc-default-10, gcc-default-11, gcc-default-12, gcc-default-13"
TERMUX_SUBPKG_CONFLICTS="gcc-default-9, gcc-default-10, gcc-default-11, gcc-default-12, gcc-default-13"
TERMUX_SUBPKG_INCLUDE="share/$TERMUX_PKG_NAME/.placeholder-14"

termux_step_create_subpkg_debscripts() {
	local _GCC_DEFAULT_VERSION=14
	echo "interest-noawait $TERMUX_PREFIX/bin/clang" >> ./triggers
	for script_type in postinst prerm; do
		sed "s|@TERMUX_PREFIX@|$TERMUX_PREFIX|g" $TERMUX_PKG_BUILDER_DIR/$script_type.sh.in |
			sed "s|@TERMUX_PKG_NAME@|$TERMUX_PKG_NAME|g" |
			sed "s|@DEFAULT_GCC_VERSION@|$_GCC_DEFAULT_VERSION|g" > ./$script_type
		chmod 0755 ./$script_type
	done
}

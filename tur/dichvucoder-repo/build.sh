TERMUX_PKG_HOMEPAGE=https://repo.dgbaodev.com
TERMUX_PKG_DESCRIPTION="Community repository maintained by Dichvucoder"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@Dichvucoder"
TERMUX_PKG_VERSION=1.0.3
TERMUX_PKG_REVISION=1
TERMUX_PKG_SKIP_SRC_EXTRACT=true
TERMUX_PKG_PLATFORM_INDEPENDENT=true

termux_step_make_install() {
	local _folder
	for _folder in bin etc include lib lib64 libexec share tmp vars; do
		mkdir -p $TERMUX_PREFIX/dichvucoder/$_folder
		mkdir -p $TERMUX_PREFIX/dgbaodev/$_folder
		touch $TERMUX_PREFIX/dichvucoder/$_folder/.placeholder
		touch $TERMUX_PREFIX/dgbaodev/$_folder/.placeholder
	done
	mkdir -p $TERMUX_PREFIX/etc/apt/sources.list.d
	echo "deb https://repo.dgbaodev.com dvc-packages dvc" > $TERMUX_PREFIX/etc/apt/sources.list.d/dichvucoder.list
	## dvc gpg key
	mkdir -p $TERMUX_PREFIX/etc/apt/trusted.gpg.d
	install -Dm600 $TERMUX_PKG_BUILDER_DIR/dvc-public.gpg $TERMUX_PREFIX/etc/apt/trusted.gpg.d/
}

termux_step_create_debscripts() {
	[ "$TERMUX_PACKAGE_FORMAT" = "pacman" ] && return 0
	echo "#!$TERMUX_PREFIX/bin/sh" > postinst
	echo "echo Downloading updated package list ..." >> postinst
	echo "apt update" >> postinst
	echo "exit 0" >> postinst
	echo "echo Modifying PATH..." >> postinst
	echo "echo \"export PATH=\\\"\$PATH:\$PREFIX/Dichvucoder/bin\\\"\" >> \$HOME/.bashrc" >> postinst
}

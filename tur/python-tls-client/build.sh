TERMUX_PKG_HOMEPAGE=https://github.com/FlorianREGAZ/Python-Tls-Client
TERMUX_PKG_DESCRIPTION="Advanced HTTP Library"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="0.2.1"
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=https://github.com/FlorianREGAZ/Python-Tls-Client/archive/refs/tags/$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=c4bef752d97a36686e4338403f3335286d8bd26d64338c4c8c571f59ec542b8a
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_DEPENDS="libc++, python, lib-tls-client"
TERMUX_PKG_PYTHON_COMMON_DEPS="wheel, 'setuptools==67.8.0'"
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_post_get_source() {
	rm -rf tls_client/dependencies/*
	touch tls_client/dependencies/__init__.py
}

termux_step_pre_configure() {
	LDFLAGS+=" -Wl,--no-as-needed -lpython${TERMUX_PYTHON_VERSION}"
}

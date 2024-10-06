TERMUX_PKG_HOMEPAGE=https://github.com/FlorianREGAZ/Python-Tls-Client
TERMUX_PKG_DESCRIPTION="Advanced HTTP Library"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="1.0.1"
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=https://github.com/FlorianREGAZ/Python-Tls-Client/archive/refs/tags/$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=789e2a1657113649772c9e20d77fc1f42db939045ca3e88b6a5714da7f2a1e8b
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_DEPENDS="libc++, python, lib-tls-client"
TERMUX_PKG_PYTHON_COMMON_DEPS="wheel"
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_post_get_source() {
	rm -rf tls_client/dependencies/*
	touch tls_client/dependencies/__init__.py
}

termux_step_pre_configure() {
	LDFLAGS+=" -Wl,--no-as-needed -lpython${TERMUX_PYTHON_VERSION}"
}

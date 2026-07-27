TERMUX_PKG_HOMEPAGE=https://github.com/javedahmed82/antigravity-termux
TERMUX_PKG_DESCRIPTION="Antigravity CLI bridge for Termux (Glibc Bridge via Ubuntu proot)"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="javedahmed82 <javedjakali82@gmail.com>"
TERMUX_PKG_VERSION=1.0.6
TERMUX_PKG_SRCURL=https://github.com/javedahmed82/antigravity-termux/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=5f5789d1dee76fa7627f64ffa9c1fe7d1ba392a303964647ec38dc18805738d6
TERMUX_PKG_DEPENDS="proot-distro, curl, tar, coreutils"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_PLATFORM_INDEPENDENT=true

termux_step_post_get_source() {
	cat << 'EOF' > LICENSE
MIT License

Copyright (c) 2026 Javed Ahmed

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO REGARDLESS OF THE FAILURE OF THIS
SOFTWARE.
EOF
}

termux_step_make_install() {
	install -Dm755 "$TERMUX_PKG_SRCDIR/install-agy.sh" "$TERMUX_PREFIX/bin/antigravity-termux-setup"
}

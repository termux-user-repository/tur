TERMUX_PKG_HOMEPAGE="https://github.com/EasyCoding/qrcodegen-cmake"
TERMUX_PKG_DESCRIPTION="High quality QR Code generator library for C and C++"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@lumaparallax"
TERMUX_PKG_VERSION="1.8.0"
TERMUX_PKG_SRCURL="https://github.com/EasyCoding/qrcodegen-cmake/archive/refs/tags/v${TERMUX_PKG_VERSION}-cmake4.tar.gz"
TERMUX_PKG_SHA256="b576111a224aa34811c81a03d8c30a13d7a048f085276b0ae87509cbf52b5ace"
TERMUX_PKG_AUTO_UPDATE=true

TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DQRCODEGEN_BUILD_EXAMPLES=OFF
-DQRCODEGEN_BUILD_TESTS=OFF
"

termux_step_post_get_source() {
	cd "$TERMUX_PKG_SRCDIR"
	# Clone to a temporary folder
	git clone https://github.com/nayuki/QR-Code-generator.git nayuki-source
	# Move the required C and C++ folders to the root (where CMakeLists.txt is)
	mv nayuki-source/c nayuki-source/cpp .
}

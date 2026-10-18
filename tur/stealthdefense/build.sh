TERMUX_PKG_HOMEPAGE=https://github.com/aleksandergrambelik-png/StealthDefense
TERMUX_PKG_DESCRIPTION="Minimalist Honeypot & Tarpit Defense (Pure Java)"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@aleksandergrambelik-png"
TERMUX_PKG_VERSION=2.6
TERMUX_PKG_SRCURL=https://github.com/aleksandergrambelik-png/StealthDefense/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_DEPENDS="openjdk-17"
TERMUX_PKG_BUILD_IN_SRC=true

TERMUX_PKG_SHA256=9cd7df72f8d87db49dfee1a6426db19975d5c98e2943d7089a9db4f865498953

termux_step_make() {
    $TERMUX_PREFIX/bin/javac -d . StealthDefense.java
}

termux_step_make_install() {
    mkdir -p $TERMUX_PREFIX/share/stealthdefense
    cp *.class $TERMUX_PREFIX/share/stealthdefense/

    cat > $TERMUX_PREFIX/bin/stealthdefense <<- EOT
#!$TERMUX_PREFIX/bin/sh
exec $TERMUX_PREFIX/bin/java -cp $TERMUX_PREFIX/share/stealthdefense StealthDefense "\$@"
EOT

    chmod 755 $TERMUX_PREFIX/bin/stealthdefense
}

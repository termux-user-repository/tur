TERMUX_PKG_HOMEPAGE=https://github.com/aleksandergrambelik-png/StealthDefense
TERMUX_PKG_DESCRIPTION="Minimalist Honeypot + Anti-Bot + Tarpit defense for Termux"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@aleksandergrambelik-png"
TERMUX_PKG_VERSION=3.0
TERMUX_PKG_SRCURL=https://github.com/aleksandergrambelik-png/StealthDefense/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=5ad636894b09f8327c7e74ee868cbf1f050aa5eabb67b1d9d95bd97f438498b3
TERMUX_PKG_DEPENDS="openjdk-17, perl, termux-api"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_PLATFORM_INDEPENDENT=true

termux_step_make() {
	$TERMUX_PREFIX/bin/javac -d . StealthDefense.java
}

termux_step_make_install() {
	mkdir -p $TERMUX_PREFIX/share/stealthdefense
	cp *.class $TERMUX_PREFIX/share/stealthdefense/
	
	cat > $TERMUX_PREFIX/bin/stealthdefense << EOT
#!$TERMUX_PREFIX/bin/sh
exec $TERMUX_PREFIX/bin/java -cp $TERMUX_PREFIX/share/stealthdefense StealthDefense "\$@"
EOT
	
	chmod 755 $TERMUX_PREFIX/bin/stealthdefense
}

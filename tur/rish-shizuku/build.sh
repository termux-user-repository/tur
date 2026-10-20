TERMUX_PKG_HOMEPAGE=https://shizuku.rikka.app
TERMUX_PKG_DESCRIPTION="Run commands with elevated privileges using Shizuku"
TERMUX_PKG_LICENSE="Apache-2.0, MIT"
TERMUX_PKG_MAINTAINER=@termux
TERMUX_PKG_VERSION=13.6.0
TERMUX_PKG_SRCURL=git+https://github.com/RikkaApps/Shizuku.git
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_PLATFORM_INDEPENDENT=true
TERMUX_PKG_ON_DEVICE_BUILD_NOT_SUPPORTED=true

termux_step_configure() {
	_check_java() (
		[[ -v JAVA_HOME ]] || return 1
		[[ -f ${JAVA_HOME}/release ]] || return 1
		# shellcheck source=/dev/null
		. "${JAVA_HOME}/release"
		((${JAVA_VERSION%%.*} == 21)) || return 1
	)

	if ! _check_java; then
		export JAVA_HOME="/usr/lib/jvm/java-21-openjdk-amd64"
		if ! _check_java; then
			termux_error_exit "No suitable JDK found, Java version 21 is required."
		fi
	fi

	export ANDROID_HOME
}

termux_step_make() {
	./gradlew :shell:build -x lint
}

termux_step_make_install() {
	local wrapper_path="${TERMUX__PREFIX__LIBEXEC_DIR}/${TERMUX_PKG_NAME}.sh"
	local dex_path="${TERMUX__PREFIX__SHARE_DIR}/${TERMUX_PKG_NAME}.dex"
	install -Dm755 /dev/stdin "${wrapper_path}" <<-WRAPPER_EOF
		#!/${TERMUX__PREFIX__BIN_DIR}/sh
		RISH_APPLICATION_ID="${TERMUX_APP__PACKAGE_NAME}" exec /system/bin/app_process -Djava.class.path="${dex_path}" /system/bin --nice-name=rish rikka.shizuku.shell.ShizukuShellLoader "\${@}"
	WRAPPER_EOF
	# Do not make the dex file writable, it causes issues on Android 14+
	install -Dm444 "${TERMUX_PKG_SRCDIR}/manager/src/main/assets/rish_shizuku.dex" "${dex_path}"
}

termux_step_create_debscripts() {
	cat >preinst <<-PREINST_EOF
		#!${TERMUX__PREFIX__BIN_DIR}/sh

		if [ ! -x /system/bin/app_process ]; then
			echo "This package requires a real Android environment, termux-docker and other similar projects are not supported" >&2
			exit 1
		fi
	PREINST_EOF
}

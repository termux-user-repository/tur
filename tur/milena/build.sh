TERMUX_PKG_HOMEPAGE="https://github.com/46Neon/Milena"
TERMUX_PKG_DESCRIPTION="Spanish programming language for data analysis"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@46Neon"
TERMUX_PKG_VERSION="0.2.0"
TERMUX_PKG_SRCURL="https://github.com/46Neon/Milena/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=56e189bbd1e89aa25a7e8588e0606f0ea42d3bf5f1086fcfa3442d632d571153
# Python is needed only by the upstream source-manifest checks.  make and
# clang are supplied by the TUR/Termux build toolchain and must not be listed
# as package dependencies (and neither is a runtime dependency).
TERMUX_PKG_BUILD_DEPENDS="python"
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_post_get_source() {
	# Keep this package tied to the canonical release layout and language path;
	# do not silently build a fork, generated artifact, or legacy runtime.
	[[ -f Makefile && -f LICENSE && -f README.md ]] || \
		termux_error_exit "Milena source is missing a required top-level file."
	[[ -d include && -d src && -d tests ]] || \
		termux_error_exit "Milena source is missing canonical source directories."
	grep -q '^MIT License$' LICENSE || \
		termux_error_exit "Milena source license is not MIT."
	grep -q '^TARGET = milena$' Makefile || \
		termux_error_exit "Refusing to build a non-canonical Milena target."
	grep -q "^#define MILENA_VERSION \"${TERMUX_PKG_VERSION}\"$" \
		include/common.h || termux_error_exit "Milena source identity/version check failed."
	for source in src/lexer.c src/parser.c src/ast.c src/language_semantic.c \
		src/language_runtime.c src/table.c; do
		[[ -f "$source" ]] || termux_error_exit "Canonical source is missing: $source"
	done

	# TUR supplies these tools in its build environment; fail early rather than
	# silently falling back to a host compiler or an incomplete build image.
	command -v make >/dev/null || termux_error_exit "TUR build environment is missing make."
	local compiler="${CC:-clang}"
	command -v "$compiler" >/dev/null || \
		termux_error_exit "TUR build environment is missing the configured C compiler: $compiler."
	"$compiler" --version 2>&1 | grep -qi clang || \
		termux_error_exit "Milena requires the Termux Clang toolchain."
	local macros
	macros=$(printf '#include <stddef.h>\n' | "$compiler" ${CPPFLAGS:-} -dM -E -x c - 2>/dev/null) || \
		termux_error_exit "Unable to query the Termux compiler predefines."
	grep -q '^#define __ANDROID__ ' <<<"$macros" || \
		termux_error_exit "Configured compiler is not targeting Android/Bionic (__ANDROID__ missing)."
	printf 'int main(void) { return 0; }\n' | "$compiler" ${CPPFLAGS:-} ${CFLAGS:-} \
		-std=c17 -fsyntax-only -x c - >/dev/null 2>&1 || \
		termux_error_exit "Configured Android/Bionic compiler does not accept C17."
}

termux_step_make() {
	make -j "${TERMUX_PKG_MAKE_PROCESSES:-1}" \
		TERMUX=1 CC="${CC:-clang}" \
		CFLAGS="${CFLAGS:-} -std=c17 -Iinclude" \
		CPPFLAGS="${CPPFLAGS:-}" LDFLAGS="${LDFLAGS:-} -lm" all
}

termux_step_make_test() {
	make -j "${TERMUX_PKG_MAKE_PROCESSES:-1}" \
		TERMUX=1 CC="${CC:-clang}" \
		CFLAGS="${CFLAGS:-} -std=c17 -Iinclude" \
		CPPFLAGS="${CPPFLAGS:-}" LDFLAGS="${LDFLAGS:-} -lm" test
}

termux_step_make_install() {
	install -Dm755 milena "${TERMUX_PREFIX}/bin/milena"
	install -Dm644 README.md "${TERMUX_PREFIX}/share/doc/${TERMUX_PKG_NAME}/README.md"
}

termux_step_post_make_install() {
	[[ -x "${TERMUX_PREFIX}/bin/milena" ]] || \
		termux_error_exit "Milena binary was not installed."
	[[ -s "${TERMUX_PREFIX}/share/doc/${TERMUX_PKG_NAME}/README.md" ]] || \
		termux_error_exit "Milena package documentation was not installed."
}

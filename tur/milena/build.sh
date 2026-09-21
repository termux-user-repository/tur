# Canonical Milena release package for TUR. Keep VERSION, SRCURL tag and
# SHA256 synchronized; never replace this tarball with a fork or generated artifact.
TERMUX_PKG_HOMEPAGE="https://github.com/46Neon/Milena"
TERMUX_PKG_DESCRIPTION="Spanish programming language for data analysis"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@46Neon"
TERMUX_PKG_VERSION="0.2.0"
TERMUX_PKG_SRCURL="https://github.com/46Neon/Milena/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256="56e189bbd1e89aa25a7e8588e0606f0ea42d3bf5f1086fcfa3442d632d571153"
# Python is build-only for upstream source guards. make, clang and Bionic are
# supplied by TUR/Termux and must not become runtime dependencies.
TERMUX_PKG_BUILD_DEPENDS="python"
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_post_get_source() {
	local compiler="${CC:-clang}" macros
	[[ -f Makefile && -f LICENSE && -f README.md && -d include && -d src && -d tests ]] || \
		termux_error_exit "Milena canonical source layout is incomplete."
	grep -q '^MIT License$' LICENSE || termux_error_exit "Milena source license is not MIT."
	grep -q '^TARGET = milena$' Makefile || termux_error_exit "Unexpected Milena target."
	grep -q "^#define MILENA_VERSION \"${TERMUX_PKG_VERSION}\"$" include/common.h || \
		termux_error_exit "Release tag and embedded Milena version disagree."
	for source in src/lexer.c src/parser.c src/ast.c src/language_semantic.c src/language_runtime.c src/table.c; do
		[[ -f "$source" ]] || termux_error_exit "Canonical source is missing: $source"
	done
	# Upstream architecture guards: fail closed, never silently skip isolation.
	command -v python3 >/dev/null || termux_error_exit "python3 is required for source guards."
	python3 scripts/check_source_manifest.py
	python3 scripts/check_experimental_isolation.py

	command -v make >/dev/null || termux_error_exit "TUR build environment is missing make."
	command -v "$compiler" >/dev/null || termux_error_exit "Configured C compiler is unavailable: $compiler."
	"$compiler" --version 2>&1 | grep -qi clang || termux_error_exit "Milena requires Termux Clang."
	macros=$(printf '#include <stddef.h>\n' | "$compiler" ${CPPFLAGS:-} -dM -E -x c - 2>/dev/null) || \
		termux_error_exit "Unable to query compiler predefines."
	grep -q '^#define __ANDROID__ ' <<<"$macros" || termux_error_exit "Compiler is not Android/Bionic (__ANDROID__ missing)."
	printf 'int main(void) { return 0; }\n' | "$compiler" ${CPPFLAGS:-} ${CFLAGS:-} -std=c17 -fsyntax-only -x c - >/dev/null 2>&1 || \
		termux_error_exit "Android/Bionic compiler does not accept C17."
}

termux_step_make() {
	make -j "${TERMUX_PKG_MAKE_PROCESSES:-1}" TERMUX=1 CC="${CC:-clang}" \
		CFLAGS="${CFLAGS:-} -std=c17 -Iinclude" CPPFLAGS="${CPPFLAGS:-}" \
		LDFLAGS="${LDFLAGS:-} -lm" all
}

# Separate test/smoke phase. TUR versions may not call this hook automatically;
# it is not evidence that every package build executed it. See RUNNER.md.
termux_step_make_test() {
	make -j "${TERMUX_PKG_MAKE_PROCESSES:-1}" TERMUX=1 CC="${CC:-clang}" \
		CFLAGS="${CFLAGS:-} -std=c17 -Iinclude" CPPFLAGS="${CPPFLAGS:-}" \
		LDFLAGS="${LDFLAGS:-} -lm" test
	./milena --version >/dev/null
}

termux_step_make_install() {
	install -Dm755 milena "${TERMUX_PREFIX}/bin/milena"
	install -Dm644 README.md "${TERMUX_PREFIX}/share/doc/${TERMUX_PKG_NAME}/README.md"
}

termux_step_post_make_install() {
	[[ -x "${TERMUX_PREFIX}/bin/milena" ]] || termux_error_exit "Milena binary was not installed."
	[[ -s "${TERMUX_PREFIX}/share/doc/${TERMUX_PKG_NAME}/README.md" ]] || termux_error_exit "Milena README was not installed."
	find "${TERMUX_PREFIX}/bin" -maxdepth 1 -type f ! -name milena -print -quit | grep -q . && \
		termux_error_exit "Unexpected executable in Milena payload." || true
}

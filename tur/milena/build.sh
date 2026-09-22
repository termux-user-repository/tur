# Canonical Milena release package for TUR. Keep VERSION, SRCURL tag and
# SHA256 synchronized; never replace this tarball with a fork or generated artifact.
TERMUX_PKG_HOMEPAGE="https://github.com/46Neon/Milena"
TERMUX_PKG_DESCRIPTION="Spanish programming language for data analysis"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_LICENSE_FILE="LICENSE"
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
	# TERMUX=1 selects Milena's canonical -Oz/section/GC defaults. Do not pass
	# CFLAGS/LDFLAGS here: TUR's flags must remain authoritative and additive.
	make -j "${TERMUX_PKG_MAKE_PROCESSES:-1}" TERMUX=1 CC="${CC:-clang}" all
}

# TUR versions may not invoke this hook. RUNNER.md documents the explicit test
# command; this hook is useful only when the runner actually schedules it.
termux_step_make_test() {
	make -j "${TERMUX_PKG_MAKE_PROCESSES:-1}" TERMUX=1 CC="${CC:-clang}" test
	./milena --version >/dev/null
}

termux_step_make_install() {
	install -Dm755 milena "${TERMUX_PREFIX}/bin/milena"
	install -Dm644 README.md "${TERMUX_PREFIX}/share/doc/${TERMUX_PKG_NAME}/README.md"
	install -Dm644 LICENSE "${TERMUX_PREFIX}/share/doc/${TERMUX_PKG_NAME}/LICENSE"
}

termux_step_post_make_install() {
	local staged_prefix="${TERMUX_PKG_MASSAGEDIR:-}${TERMUX_PREFIX:-}"
	[[ -n "${TERMUX_PKG_MASSAGEDIR:-}" && -d "$staged_prefix" ]] || \
		termux_error_exit "TUR staging root is unavailable; refusing global-prefix validation."
	[[ -x "$staged_prefix/bin/milena" ]] || termux_error_exit "Milena binary is absent from staging."
	for file in "$staged_prefix/share/doc/${TERMUX_PKG_NAME}/README.md" "$staged_prefix/share/doc/${TERMUX_PKG_NAME}/LICENSE"; do
		[[ -s "$file" ]] || termux_error_exit "Required staged artifact is absent: $file"
	done
	# The package payload is deliberately closed: TUR metadata is generated separately.
	local actual expected
	expected=$'bin/milena\nshare/doc/'"${TERMUX_PKG_NAME}"$'/README.md\nshare/doc/'"${TERMUX_PKG_NAME}"$'/LICENSE'
	actual=$(find "$staged_prefix" -type f -printf '%P\n' | sort)
	[[ "$actual" == "$(printf '%s\n' "$expected" | sort)" ]] || \
		termux_error_exit "Unexpected staged payload (expected binary and README/license only)."

	# Do not silently skip this audit: it rejects host binaries and unreviewed deps.
	local readelf_bin needed
	readelf_bin="$(command -v llvm-readelf || command -v readelf || true)"
	[[ -n "$readelf_bin" ]] || termux_error_exit "No llvm-readelf/readelf available for ELF audit."
	"$readelf_bin" -h "$staged_prefix/bin/milena" >/dev/null || termux_error_exit "Staged Milena file is not ELF."
	needed=$("$readelf_bin" -d "$staged_prefix/bin/milena" 2>/dev/null | sed -n 's/.*Shared library: \[\([^]]*\)\].*/\1/p')
	while IFS= read -r lib; do
		case "$lib" in libc.so|libm.so|libdl.so|liblog.so|libc.so.*|libm.so.*) ;; *) termux_error_exit "Unexpected Android DT_NEEDED entry: $lib" ;; esac
	done <<<"$needed"

}


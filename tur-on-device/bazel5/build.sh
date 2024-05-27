TERMUX_PKG_HOMEPAGE=https://bazel.build/
TERMUX_PKG_DESCRIPTION="Correct, reproducible, and fast builds for everyone"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="5.4.1"
TERMUX_PKG_SRCURL=https://github.com/bazelbuild/bazel/releases/download/$TERMUX_PKG_VERSION/bazel-$TERMUX_PKG_VERSION-dist.zip
TERMUX_PKG_SHA256=dcff6935756aa7aca4fc569bb2bd26e1537f0b1f6d1bda5f2b200fa835cc507f
TERMUX_PKG_DEPENDS="libarchive, openjdk-17, patch, unzip, zip"
TERMUX_PKG_BUILD_DEPENDS="libandroid-spawn-static, which"
TERMUX_PKG_BREAKS="openjdk-11"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_BLACKLISTED_ARCHES="arm, i686"
TERMUX_PKG_NO_STRIP=true

__ensure_is_on_device_compile() {
	if [ "${TERMUX_ON_DEVICE_BUILD}" = false ]; then
		termux_error_exit "This package doesn't support cross-compiling."
	fi
}

__sed_verbose() {
	local path=$1; shift;
	sed --follow-symlinks -i".bak-nix" "$@" "$path"
	diff -U0 "$path.bak-nix" "$path" | sed "s/^/  /" || true
	rm -f "$path.bak-nix"
}

__fix_harcoded_paths() {
	# Ref: https://github.com/NixOS/nixpkgs/blob/release-23.11/pkgs/development/tools/build-managers/bazel/bazel_7/default.nix

	# Unzip builtins_bzl.zip so the contents get patched
	local builtins_bzl=src/main/java/com/google/devtools/build/lib/bazel/rules/builtins_bzl
	unzip ${builtins_bzl}.zip -d ${builtins_bzl}_zip >/dev/null
	rm ${builtins_bzl}.zip
	builtins_bzl=''${builtins_bzl}_zip/builtins_bzl

	echo
	echo "Substituting */bin/* hardcoded paths in src/main/java/com/google/devtools"
	# Prefilter the files with grep for speed
	grep -rlZ /bin/ \
		src/main/java/com/google/devtools \
		tools \
	| while IFS="" read -r -d "" path; do
		# If you add more replacements here, you must change the grep above!
		# Only files containing /bin are taken into account.
		__sed_verbose "$path" \
			-e "s!/usr/local/bin/bash!${TERMUX_PREFIX}/bin/bash!g" \
			-e "s!/usr/bin/bash!${TERMUX_PREFIX}/bin/bash!g" \
			-e "s!/bin/bash!${TERMUX_PREFIX}/bin/bash!g" \
			-e "s!/usr/bin/env bash!${TERMUX_PREFIX}/bin/bash!g" \
			-e "s!/usr/bin/env python2!${TERMUX_PREFIX}/bin/python!g" \
			-e "s!/usr/bin/env python!${TERMUX_PREFIX}/bin/python!g" \
			-e "s!/usr/bin/env!${TERMUX_PREFIX}/bin/env!g" \
			-e "s!/bin/true!${TERMUX_PREFIX}/bin/true!g"
	done

	# Fixup scripts that generate scripts. Not fixed up by patchShebangs below.
	__sed_verbose scripts/bootstrap/compile.sh \
		-e "s!/bin/bash!${TERMUX_PREFIX}/bin/bash!g"

	# reconstruct the now patched builtins_bzl.zip
	pushd src/main/java/com/google/devtools/build/lib/bazel/rules/builtins_bzl_zip &>/dev/null
		zip ../builtins_bzl.zip $(find builtins_bzl -type f) >/dev/null
		rm -rf builtins_bzl
	popd &>/dev/null
	rmdir src/main/java/com/google/devtools/build/lib/bazel/rules/builtins_bzl_zip

	# Fix shebangs
	while IFS= read -r -d '' file; do
		if head -c 100 "$file" | head -n 1 | grep -E "^#!.*/bin/.*" | grep -q -E -v "^#! ?$TERMUX_PREFIX"; then
			__sed_verbose "$file" -E "1 s@^#\!(.*)/bin/(.*)@#\!$TERMUX_PREFIX/bin/\2@"
		fi
	done < <(find -L . -type f -print0)
}

termux_step_get_source() {
	local f="$(basename "${TERMUX_PKG_SRCURL}")"
	termux_download \
		"${TERMUX_PKG_SRCURL}" \
		"$TERMUX_PKG_CACHEDIR/${f}" \
		"${TERMUX_PKG_SHA256}"
	mkdir -p "$TERMUX_PKG_SRCDIR"
	unzip -d "$TERMUX_PKG_SRCDIR" "$TERMUX_PKG_CACHEDIR/${f}" > /dev/null
}

termux_step_post_get_source() {
	# Fix hardcoded paths
	__fix_harcoded_paths

	# Copy patches
	rm -rf third_party/termux-patches/
	mkdir -p third_party/termux-patches/
	cp -Rfv $TERMUX_PKG_BUILDER_DIR/dep-patches/* third_party/termux-patches/
}

termux_step_pre_configure() {
	__ensure_is_on_device_compile

	# Ensure openjdk-17 is installed
	# apt autoremove --purge openjdk* -y
	# apt install --reinstall openjdk-17 -y

	export JAVA_HOME="$TERMUX_PREFIX/lib/jvm/java-17-openjdk"
}

termux_step_make() {
	# Compile bazel
	local EXTRA_BAZEL_ARGS=""
	# EXTRA_BAZEL_ARGS+=" --keep_going"
	EXTRA_BAZEL_ARGS+=" --verbose_failures"
	EXTRA_BAZEL_ARGS+=" --action_env=ANDROID_DATA"
	EXTRA_BAZEL_ARGS+=" --action_env=ANDROID_ROOT"
	EXTRA_BAZEL_ARGS+=" --action_env=LD_PRELOAD"
	EXTRA_BAZEL_ARGS+=" --tool_java_runtime_version=local_jdk"
	EMBED_LABEL=$TERMUX_PKG_VERSION EXTRA_BAZEL_ARGS="$EXTRA_BAZEL_ARGS" VERBOSE=1 ./compile.sh
}

termux_step_make_install() {
	install -Dm700 ./output/bazel $TERMUX_PREFIX/bin/bazel-$TERMUX_PKG_VERSION
}

termux_step_post_massage() {
	rm -rf lib var share/doc/openjdk-17
}

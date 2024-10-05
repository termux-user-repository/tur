#!/bin/bash
# This file is inspired by the `run.sh` in `ungoogled-chromium-archlinux`,
# which is licenced under BSD-3 Clause. The licence is as listed following.
#
##  Copyright 2022 The ungoogled-chromium Authors. All rights reserved.
#
##  Redistribution and use in source and binary forms, with or without
##  modification, are permitted provided that the following conditions are
##  met:
#
##  * Redistributions of source code must retain the above copyright
##    notice, this list of conditions and the following disclaimer.
##  * Redistributions in binary form must reproduce the above
##    copyright notice, this list of conditions and the following disclaimer
##    in the documentation and/or other materials provided with the
##    distribution.
##  * Neither the name of the copyright holder nor the names of its
##    contributors may be used to endorse or promote products derived from
##    this software without specific prior written permission.
#
##  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
##  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
##  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
##  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
##  OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
##  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
##  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
##  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
##  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
##  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
##  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# The origin file URL is: 
# https://github.com/ungoogled-software/ungoogled-chromium-archlinux/blob/master/.github/workflows/container/run.sh


: "${TUR_CONTINUOUS_FLAG:=false}"
: "${TUR_CONTINUOUS_TIMEOUT:=200m}"

# XXX: For the CI, we always pass the packages as the last param.
TUR_CONTINUOUS_PACKAGE="${@: -1}"

echo "==> Package to be built: $TUR_CONTINUOUS_PACKAGE"

# Get the builder docker image if necessary.
./scripts/run-docker.sh bash -c "exit 0"

# Create the output dir, it may be used to construct the status.
./scripts/run-docker.sh bash -c "mkdir -p ./output"

# Install zstd
echo "==> Installing zstd"
./scripts/run-docker.sh bash -c "sudo apt update && sudo apt install -yq zstd"

echo "==> Build with continuous flag: $TUR_CONTINUOUS_FLAG"
echo "==> Build with timeout: $TUR_CONTINUOUS_TIMEOUT"

EXTRA_FLAGS=""
if [ "$TUR_CONTINUOUS_FLAG" != "false" ]; then
	EXTRA_FLAGS="-c"
	echo "==> Extracting the build deps..."
	# Extract build deps to docker
	time ./scripts/run-docker.sh bash -c 'sudo tar -I zstd -C / -xf ./build-deps/tur-continuous-deps.tar.zst'
	rm -f ./build-deps/tur-continuous-deps.tar.zst
	echo "==> Extracting the build status..."
	# Extract build status to docker
	time ./scripts/run-docker.sh bash -c 'sudo tar -I zstd -C / -xf ./build-status/tur-continuous-status.tar.zst'
	rm -f ./build-status/tur-continuous-status.tar.zst
fi

echo "==> Current time: $(date)"

# Start the build process with or without continuous flag
timeout -k 10m -s SIGTERM "$TUR_CONTINUOUS_TIMEOUT" ./scripts/run-docker.sh "$@" $EXTRA_FLAGS
EXIT_CODE=$?

mkdir -p ./build-status ./build-deps

if [[ $EXIT_CODE == 0 ]]; then
	echo "==> Build successful"
	echo "true" > ./build-status/tur-continuous-finished-flag
	echo "true" > ./build-deps/.placeholder
	# XXX: Seems that action artifacts will not delete the uploaded files automatically.
	touch ./build-status/tur-continuous-status.tar.zst
elif [[ $EXIT_CODE == 124 ]]; then # https://www.gnu.org/software/coreutils/manual/html_node/timeout-invocation.html#timeout-invocation
	echo "==> Build timed out"
	echo "false" > ./build-status/tur-continuous-finished-flag
	echo "==> Generating the build status..."
	df -h
	# XXX: This will create a pretty large file, hope that Github Action has enough space.
	# XXX: I think the build status is just the `build` folder. If this package performs
	# XXX: an in-source building, please move the origin `src` folder to `build` folder
	# XXX: and use symlinks to provide `src` folder. Folder like `src`, `cache`, or `tmp`
	# XXX: often contains the source files or scripts and will not be modified during 
	# XXX: the building process.
	time ./scripts/run-docker.sh bash -c 'sudo tar -I zstd --remove-files -cf ./build-status/tur-continuous-status.tar.zst /home/builder/.termux-build/'"$TUR_CONTINUOUS_PACKAGE"'/build'
	echo "==> Successfully generate build status."
	# Create the deps file if the package is built the first time.
	if [ "$TUR_CONTINUOUS_FLAG" = "false" ]; then
		echo "==> Generating the build deps..."
		df -h
		# XXX: This will create a pretty large file, hope that Github Action has enough space.
		time ./scripts/run-docker.sh bash -c 'sudo tar -I zstd --remove-files -cf ./build-deps/tur-continuous-deps.tar.zst /data /home/builder/.termux-build'
		echo "==> Successfully generate build deps."
	fi
else
	echo "==> Build failed with $EXIT_CODE"
	exit $EXIT_CODE
fi

#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
#
# Copyright (C) 2025 Collabora, Vignesh Raman <vignesh.raman@collabora.com>
#
# Based on the build-deqp-runner.sh script from the mesa project:
# https://gitlab.freedesktop.org/mesa/mesa/-/blob/main/.gitlab-ci/container/build-deqp-runner.sh
#
# shellcheck disable=SC2086 # we want word splitting

set -uex

DEQP_RUNNER_GIT_URL="${DEQP_RUNNER_GIT_URL:-https://gitlab.freedesktop.org/mesa/deqp-runner.git}"
DEQP_RUNNER_GIT_TAG="${DEQP_RUNNER_GIT_TAG:-v0.20.0}"

git clone $DEQP_RUNNER_GIT_URL --single-branch --no-checkout
pushd deqp-runner
git checkout $DEQP_RUNNER_GIT_TAG

RUST_TARGET="${RUST_TARGET:-}"

# When CC (/usr/lib/ccache/gcc) variable is set, the rust compiler uses
# this variable when cross-compiling arm32 and build fails for zsys-sys.
# So unset the CC variable when cross-compiling for arm32.
SAVEDCC=${CC:-}
if [ "$RUST_TARGET" = "armv7-unknown-linux-gnueabihf" ]; then
    unset CC
fi
cargo install --locked  \
    -j ${FDO_CI_CONCURRENT:-4} \
    --root /usr/local \
    ${EXTRA_CARGO_ARGS:-} \
    --path .
CC=$SAVEDCC

popd
rm -rf deqp-runner

# remove unused test runners
if [ -z "${DEQP_RUNNER_GIT_TAG:-}" ]; then
    rm -f /usr/local/bin/igt-runner
fi

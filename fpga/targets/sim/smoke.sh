#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Copyright 2026 India AI Inference Chip v1.0 contributors

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "${repo_root}"

# Board-neutral smoke gate used before wiring a real FPGA top-level.
make mmio-test matrix-test scratchpad-test dma-test dma-matrix-test

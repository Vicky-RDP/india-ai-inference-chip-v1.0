#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Copyright 2026 India AI Inference Chip v1.0 contributors

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
report_dir="${1:-${repo_root}/build/synthesis}"
yosys_bin="${YOSYS:-yosys}"

if ! command -v "${yosys_bin}" >/dev/null 2>&1; then
    echo "yosys not installed; synthesis report skipped (install Yosys to run it)"
    exit 0
fi

mkdir -p "${report_dir}"
report_path="${report_dir}/ii_inference_processor.rpt"
netlist_path="${report_dir}/ii_inference_processor.json"

cd "${repo_root}"
"${yosys_bin}" -p \
    "read_verilog -sv rtl/ii_dot_product.sv rtl/ii_dot_product_stream.sv rtl/ii_inference_processor.sv; \
     hierarchy -top ii_inference_processor; \
     synth -top ii_inference_processor; \
     check; \
     stat; \
     write_json ${netlist_path}" \
    | tee "${report_path}"

echo "synthesis report: ${report_path}"
echo "synthesis netlist: ${netlist_path}"

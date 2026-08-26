#!/usr/bin/env python3
"""Deterministic randomized cross-check of the RTL against Python arithmetic."""

from __future__ import annotations

import os
import random
import shutil
import subprocess
import tempfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
LANES = 16
SEED = 20260826
VECTOR_COUNT = 256
INT8_MIN = -128
INT8_MAX = 127


def pack(values: list[int]) -> int:
    return sum((value & 0xFF) << (lane * 8) for lane, value in enumerate(values))


def make_vectors() -> list[tuple[list[int], list[int], int]]:
    rng = random.Random(SEED)
    vectors = [
        ([0] * LANES, [0] * LANES),
        ([INT8_MAX] * LANES, [INT8_MIN] * LANES),
        ([INT8_MIN if lane % 2 else INT8_MAX for lane in range(LANES)], [1] * LANES),
    ]
    vectors.extend(
        (
            [rng.randint(INT8_MIN, INT8_MAX) for _ in range(LANES)],
            [rng.randint(INT8_MIN, INT8_MAX) for _ in range(LANES)],
        )
        for _ in range(VECTOR_COUNT - len(vectors))
    )
    return [(activations, weights, sum(a * w for a, w in zip(activations, weights))) for activations, weights in vectors]


def testbench(vectors: list[tuple[list[int], list[int], int]]) -> str:
    lines = [
        "module ii_dot_product_random_tb;",
        f"  localparam int LANES = {LANES};",
        "  logic clk = 1'b0, rst_n = 1'b0, valid_in = 1'b0;",
        "  logic [LANES*8-1:0] activations = '0, weights = '0;",
        "  logic valid_out;",
        "  logic signed [31:0] result;",
        "  integer signed expected;",
        "  always #5 clk = ~clk;",
        "  ii_dot_product #(.LANES(LANES), .ACC_WIDTH(32)) dut (.*);",
        "  initial begin",
        "    repeat (2) @(negedge clk);",
        "    rst_n = 1'b1;",
    ]
    for index, (activations, weights, expected) in enumerate(vectors):
        lines.extend(
            [
                f"    // Vector {index}",
                "    @(negedge clk);",
                f"    activations = 128'h{pack(activations):032x};",
                f"    weights = 128'h{pack(weights):032x};",
                f"    expected = {expected};",
                "    valid_in = 1'b1;",
                "    @(posedge clk); #1;",
                f"    if (!valid_out || $signed(result) !== expected) $fatal(1, \"vector {index} failed: got %0d expected %0d\", result, expected);",
                "    valid_in = 1'b0;",
            ]
        )
    lines.extend(
        [
            "    $display(\"ii_dot_product_random_tb: PASS (%0d vectors, seed %0d)\", ",
            f"      {len(vectors)}, {SEED});",
            "    $finish;",
            "  end",
            "endmodule",
            "",
        ]
    )
    return "\n".join(lines)


def main() -> None:
    simulator = os.environ.get("SIM", "iverilog")
    if shutil.which(simulator) is None:
        raise SystemExit(f"simulator not found: {simulator}")
    vectors = make_vectors()
    with tempfile.TemporaryDirectory(prefix="iaic-random-") as directory:
        work = Path(directory)
        testbench_path = work / "ii_dot_product_random_tb.sv"
        output_path = work / "ii_dot_product_random_tb"
        testbench_path.write_text(testbench(vectors), encoding="utf-8")
        subprocess.run(
            [simulator, "-g2012", "-Wall", "-o", str(output_path), str(ROOT / "rtl/ii_dot_product.sv"), str(testbench_path)],
            check=True,
            cwd=ROOT,
        )
        subprocess.run(["vvp", str(output_path)], check=True, cwd=ROOT)


if __name__ == "__main__":
    main()

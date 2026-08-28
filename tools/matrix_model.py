#!/usr/bin/env python3
"""Bit-accurate reference model for the IAIC streamed matrix tile."""

from __future__ import annotations

from collections.abc import Sequence

from iaic_operator import int8_dot_product, pack_int8, to_int8


def pack_rows(rows: Sequence[Sequence[int]]) -> int:
    """Pack contiguous rows with row 0 and lane 0 in the least-significant byte."""

    if not rows or not rows[0]:
        raise ValueError("rows must be non-empty")
    width = len(rows[0])
    if any(len(row) != width for row in rows):
        raise ValueError("all rows must have the same width")
    row_bits = width * 8
    return sum(pack_int8(row) << (index * row_bits) for index, row in enumerate(rows))


def unpack_rows(packed: int, row_count: int, width: int) -> list[list[int]]:
    """Unpack the contiguous row representation used by the matrix tile."""

    if row_count < 1 or width < 1:
        raise ValueError("row count and width must be positive")
    return [
        [to_int8((packed >> (row * width * 8 + lane * 8)) & 0xFF) for lane in range(width)]
        for row in range(row_count)
    ]


def pack_tile_result(outputs: Sequence[Sequence[int]], *, acc_width: int = 32) -> int:
    """Pack row-major signed accumulator outputs into the RTL result vector."""

    if not outputs or not outputs[0] or any(len(row) != len(outputs[0]) for row in outputs):
        raise ValueError("outputs must be a non-empty rectangular matrix")
    if acc_width < 1:
        raise ValueError("accumulator width must be positive")
    mask = (1 << acc_width) - 1
    flat_values = [value for row in outputs for value in row]
    return sum((value & mask) << (index * acc_width) for index, value in enumerate(flat_values))


def matrix_tile(
    activations: Sequence[Sequence[int]],
    weights: Sequence[Sequence[int]],
    *,
    acc_width: int = 32,
) -> list[list[int]]:
    """Return MxN outputs for M activation rows and N weight rows."""

    if not activations or not weights:
        raise ValueError("matrix tile dimensions must be non-zero")
    k = len(activations[0])
    if k == 0 or any(len(row) != k for row in activations + weights):
        raise ValueError("all matrix rows must have the same non-zero K")
    return [
        [int8_dot_product(activation_row, weight_row, acc_width=acc_width) for weight_row in weights]
        for activation_row in activations
    ]

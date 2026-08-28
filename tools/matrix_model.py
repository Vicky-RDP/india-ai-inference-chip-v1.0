#!/usr/bin/env python3
"""Bit-accurate reference model for the IAIC streamed matrix tile."""

from __future__ import annotations

from collections.abc import Sequence

from iaic_operator import int8_dot_product


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

#!/usr/bin/env python3
"""Small host-side INT8 operator API matching the IAIC v1.0 RTL contract."""

from __future__ import annotations

from collections.abc import Sequence

from reference_model import INT8_MAX, INT8_MIN, to_int8


def _validate_int8(values: Sequence[int]) -> None:
    if any(not INT8_MIN <= value <= INT8_MAX for value in values):
        raise ValueError("all inputs must fit signed INT8")


def pack_int8(values: Sequence[int]) -> int:
    """Pack lane 0 into the least-significant byte, as the RTL does."""

    _validate_int8(values)
    return sum((value & 0xFF) << (lane * 8) for lane, value in enumerate(values))


def unpack_int8(packed: int, lanes: int) -> list[int]:
    """Unpack a packed IAIC vector into signed INT8 lane values."""

    if lanes < 0:
        raise ValueError("lane count cannot be negative")
    return [to_int8(packed >> (lane * 8)) for lane in range(lanes)]


def int8_dot_product(
    activations: Sequence[int],
    weights: Sequence[int],
    *,
    acc_width: int = 32,
) -> int:
    """Compute the signed INT8 dot product with an explicit accumulator width."""

    if len(activations) != len(weights):
        raise ValueError("activation and weight vectors must have equal length")
    if acc_width < 1:
        raise ValueError("accumulator width must be positive")
    _validate_int8(activations)
    _validate_int8(weights)
    result = sum(activation * weight for activation, weight in zip(activations, weights))
    minimum = -(1 << (acc_width - 1))
    maximum = (1 << (acc_width - 1)) - 1
    if not minimum <= result <= maximum:
        raise OverflowError(f"result does not fit a signed {acc_width}-bit accumulator")
    return result


def packed_int8_dot_product(
    packed_activations: int,
    packed_weights: int,
    lanes: int,
    *,
    acc_width: int = 32,
) -> int:
    """Compute directly from the two packed vectors used by the processor."""

    return int8_dot_product(
        unpack_int8(packed_activations, lanes),
        unpack_int8(packed_weights, lanes),
        acc_width=acc_width,
    )

#!/usr/bin/env python3
"""Bit-accurate reference behavior for the v0 INT8 dot-product core."""

from __future__ import annotations

INT8_MIN = -128
INT8_MAX = 127
ACC_MIN = -(1 << 31)
ACC_MAX = (1 << 31) - 1


def to_int8(value: int) -> int:
    value &= 0xFF
    return value - 0x100 if value & 0x80 else value


def dot_product(activations: list[int], weights: list[int]) -> int:
    if len(activations) != len(weights):
        raise ValueError("activation and weight vectors must have equal length")
    if any(not INT8_MIN <= value <= INT8_MAX for value in activations + weights):
        raise ValueError("all inputs must fit signed INT8")
    result = sum(activation * weight for activation, weight in zip(activations, weights))
    if not ACC_MIN <= result <= ACC_MAX:
        raise OverflowError("result does not fit the v0 signed 32-bit accumulator")
    return result


def main() -> None:
    vectors = [
        ([1, -2, 3, -4], [2, 3, -4, -5]),
        ([127, -128, 0, -1], [127, -128, 0, 1]),
    ]
    for activations, weights in vectors:
        print(f"{activations} · {weights} = {dot_product(activations, weights)}")

    assert to_int8(0x7F) == 127
    assert to_int8(0x80) == -128
    assert dot_product([1, -2, 3, -4], [2, 3, -4, -5]) == 4
    assert dot_product([127, -128, 0, -1], [127, -128, 0, 1]) == 32512
    print("reference_model: PASS")


if __name__ == "__main__":
    main()

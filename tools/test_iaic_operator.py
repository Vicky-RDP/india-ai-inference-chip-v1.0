#!/usr/bin/env python3
"""Unit tests for the host-side IAIC INT8 operator API."""

import unittest

from iaic_operator import int8_dot_product, pack_int8, packed_int8_dot_product, unpack_int8


class IaicOperatorTest(unittest.TestCase):
    def test_pack_and_unpack_preserve_lane_order(self):
        values = [1, -2, 3, -4]
        self.assertEqual(pack_int8(values), 0xFC03FE01)
        self.assertEqual(unpack_int8(0xFC03FE01, 4), values)

    def test_packed_dot_product_matches_rtl_example(self):
        self.assertEqual(
            packed_int8_dot_product(0xFC03FE01, 0xFBFC0302, 4),
            4,
        )

    def test_signed_edge_values(self):
        self.assertEqual(int8_dot_product([127, -128], [127, -128]), 32513)

    def test_rejects_invalid_input(self):
        with self.assertRaises(ValueError):
            pack_int8([128])
        with self.assertRaises(ValueError):
            int8_dot_product([1], [1, 2])

    def test_checks_accumulator_width(self):
        with self.assertRaises(OverflowError):
            int8_dot_product([127, 127], [127, 127], acc_width=8)


if __name__ == "__main__":
    unittest.main()

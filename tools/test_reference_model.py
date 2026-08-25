#!/usr/bin/env python3
"""Small standard-library regression for the public numeric contract."""

import unittest

from reference_model import dot_product, to_int8


class ReferenceModelTest(unittest.TestCase):
    def test_signed_vectors(self):
        self.assertEqual(dot_product([1, -2, 3, -4], [2, 3, -4, -5]), 4)
        self.assertEqual(dot_product([127, -128, 0, -1], [127, -128, 0, 1]), 32512)

    def test_vector_length_and_range(self):
        with self.assertRaises(ValueError):
            dot_product([1], [1, 2])
        with self.assertRaises(ValueError):
            dot_product([128], [1])

    def test_int8_conversion(self):
        self.assertEqual(to_int8(0x7F), 127)
        self.assertEqual(to_int8(0x80), -128)
        self.assertEqual(to_int8(0xFF), -1)


if __name__ == "__main__":
    unittest.main()


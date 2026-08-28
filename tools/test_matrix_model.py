#!/usr/bin/env python3
"""Unit tests for the IAIC matrix-tile golden model."""

import unittest

from matrix_model import matrix_tile, pack_rows, pack_tile_result, unpack_rows


class MatrixModelTest(unittest.TestCase):
    def test_two_by_two_tile(self):
        activations = [[1, 2, 3], [4, 5, 6]]
        weights = [[1, 0, -1], [2, 1, 0]]
        self.assertEqual(matrix_tile(activations, weights), [[-2, 4], [-2, 13]])

    def test_signed_edges(self):
        self.assertEqual(matrix_tile([[-128, 127]], [[-128, 127]]), [[32513]])

    def test_rejects_ragged_rows(self):
        with self.assertRaises(ValueError):
            matrix_tile([[1, 2], [3]], [[1, 2]])

    def test_packed_rows_and_outputs(self):
        rows = [[1, 2, 3], [4, 5, 6]]
        packed = pack_rows(rows)
        self.assertEqual(packed, 0x060504030201)
        self.assertEqual(unpack_rows(packed, 2, 3), rows)
        self.assertEqual(pack_tile_result([[-2, 4], [-2, 13]]), 0x0000000DFFFFFFFE00000004FFFFFFFE)


if __name__ == "__main__":
    unittest.main()

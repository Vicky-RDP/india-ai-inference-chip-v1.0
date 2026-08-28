#!/usr/bin/env python3
"""Unit tests for the IAIC matrix-tile golden model."""

import unittest

from matrix_model import matrix_tile


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


if __name__ == "__main__":
    unittest.main()
